import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

//private let reuseIdentifier = "Cell"

class HomeViewController: UICollectionViewController {

    //刷新控件,用于表格视图或集合视图上处理网络数据刷新
    var refresher = UIRefreshControl()
    
    //每一页载入帖子的数量
    var postPerPage: Int = 12
    
    var postIdArray = [String]()
    var pictureArray = [AVFile]()
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置导航栏中的title
        self.navigationItem.title = AVUser.current()?.username
        
        //设置refresher控件到CollectionView中
        //refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        collectionView.addSubview(refresher)
        
        //载入用户的posts
        loadPosts()
    }

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 0
//    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 确定Collection中需要多少单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        //return pictureArray.count
        return pictureArray.count
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 将图片载入到cell中
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //从CollectionView中获取单元格对象
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        //从PictureArray中提取图片
        pictureArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.cellImage.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription)
            }
        }

        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 当ColloctionView在屏幕上显示附属视图的时候调用
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //从CollectionView的可复用队列中获取Header View
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HomeHeaderView
        
        //获取用户信息
        let currentUser = AVUser.current()!
        header.displayName.text = currentUser.object(forKey: "displayName") as? String
        header.bio.text = currentUser.object(forKey: "bio") as? String
        header.bio.sizeToFit() //调整试图大小为包裹所显示文字内容
        
        //获取头像
        //改变profile image为圆形
        header.profileImage.layer.cornerRadius = header.profileImage.frame.width / 2
        header.profileImage.clipsToBounds = true //减掉多余的部分
        
        let profileImageQuery = currentUser.object(forKey: "profileImage") as? AVFile
        profileImageQuery?.getDataInBackground({ (data: Data?, error: Error?) in
            if data == nil {
                print(error?.localizedDescription as Any)
            }
            else {
                header.profileImage.image = UIImage(data: data!)
            }
        })

        //查找Post个数
        let postCount = AVQuery(className: "Posts")
        postCount.whereKey("username", equalTo: currentUser.username as Any)
        postCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = String(count)
            }
        }
        
        //查找Follower个数
        let followersCount = AVQuery(className: "_Follower")
        followersCount.whereKey("user", equalTo: currentUser)
        followersCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = String(count)
            }
        }
        
        //查找Following个数
        let followingsCount = AVQuery(className: "_Followee")
        followingsCount.whereKey("user", equalTo: currentUser)
        followingsCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = String(count)
            }
        }
        
        //单击手势：单击“帖子”
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTapAction))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //单击手势：单击“关注者”
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTapAction))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //单击手势：单击“关注”
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTapAction))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 刷新页面方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func refresh() {
        collectionView.reloadData()
        //停止动画刷新
        refresher.endRefreshing()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 载入帖子到设置的Array中
    /////////////////////////////////////////////////////////////////////////////////
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username)
        query.limit = postPerPage
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //如果查询成功，清空两个Array
                self.postIdArray.removeAll(keepingCapacity: false)
                self.pictureArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    //将查询到的数据x添加到数组中
                    self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                    self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                }
                
                self.collectionView.reloadData()
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 单击”帖子“后调用方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func postsTapAction() {
        //如果PictureArray中有值的话讲视图滚动到第一个Section的第一个Item上
        if !pictureArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 单击”关注者“后调用方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func followersTapAction() {
        //载入FollowViewController的视图
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
        followers.user = AVUser.current()!.username!
        followers.show = "Followers"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 单击”关注“后调用方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func followingsTapAction() {
        //载入FollowViewController的视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
        followings.user = AVUser.current()!.username!
        followings.show = "Followings"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
}
