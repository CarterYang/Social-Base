import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

//全局变量，用来储存当前用户所浏览的关注人员队列
var guestArray = [AVUser]()

class GuestViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var postIdArray = [String]()
    var pictureArray = [AVFile]()
    
    //刷新控件,负责滚动视图拉拽的刷新动画
    var refresher = UIRefreshControl()
    
    //每次从云端下载照片的数量
    var postPerPage: Int = 12
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        //允许垂直的拉拽刷新动作
        self.collectionView.alwaysBounceVertical = true
        
        //设置导航栏中的title
        self.navigationItem.title = guestArray.last?.username
        
        //定义导航栏中的返回按钮
        self.navigationItem.hidesBackButton = true
        //let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        
        //实现向右滑返回效果
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        //设置refresher控件到CollectionView中
        refresher.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        collectionView.addSubview(refresher)
        
        //设置CollectionView的背景色为白色
        self.collectionView.backgroundColor = .white
        
        //载入用户的posts
        loadPosts()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设置单元格布局
    /////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.view.frame.width - 2) / 3, height: (self.view.frame.width - 2) / 3)
        return size
    }
    
    //    //该方法是用来设置 CollectionViewCell 四周的边距
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    //    }
    //
    //该方法是用来设置同一行 CollectionViewCell 之间的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //该方法是用来设置同一列 CollectionViewCell 之间的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 确定Collection中需要多少单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pictureArray.count
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 配置单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //定义Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        //从PictureArray中提取图片
        pictureArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.cellImage.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription ?? "无法获取帖子")
            }
        }
        
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 配置Header
    /////////////////////////////////////////////////////////////////////////////////
    //当ColloctionView在屏幕上显示附属视图的时候调用
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //定义Header: 从CollectionView的可复用队列中获取Header View
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HomeHeaderView
        
        //Step 1: 载入访客的基本数据信息
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last!.username!)            //注意：这里有改动last?.username
        infoQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                
                //判断用户是否有数据
                guard let objects = objects, objects.count > 0 else {
                    return
                }
                
                //找到用户相关信息
                for object in objects {
                    header.displayName.text = (object as AnyObject).object(forKey: "displayName") as? String
                    header.bio.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bio.sizeToFit() //调整试图大小为包裹所显示文字内容
            
                    //获取头像
                    //改变profile image为圆形
                    header.profileImage.layer.cornerRadius = header.profileImage.frame.width / 2
                    header.profileImage.clipsToBounds = true //减掉多余的部分
            
                    let profileImageQuery = (object as AnyObject).object(forKey: "profileImage") as? AVFile
                    profileImageQuery?.getDataInBackground({ (data: Data?, error: Error?) in
                        if data == nil {
                            print(error?.localizedDescription as Any)
                        }
                        else {
                            header.profileImage.image = UIImage(data: data!)
                        }
                    })
                }
            }
            else {
                print(error?.localizedDescription ?? "无法载入访客基本信息")
            }
        }
        
        //Step 2: 设置当前用户与访客之间关注状态
        let query = AVUser.current()?.followeeQuery()
        query?.whereKey("user", equalTo: AVUser.current()!)
        query?.whereKey("followee", equalTo: guestArray.last!)
        //查看是否关注
        query?.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                if count == 0 {
                    header.editProfile.setTitle("关 注", for: .normal)
                    header.editProfile.backgroundColor = .lightGray
                }
                else {
                    header.editProfile.setTitle("已关注", for: .normal)
                    header.editProfile.backgroundColor = self.hexStringToUIColor(hex: "#26BAEE")
                }
            }
        }
        
        //Step 3: 设置统计数据
        //查找Post个数
        let postCount = AVQuery(className: "Posts")
        postCount.whereKey("username", equalTo: guestArray.last!.username!)   //注意：这里有改动last?.username
        postCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.posts.text = String(count)
            }
        }
        
        //查找Follower个数
        let followersCount = AVQuery(className: "_Follower")
        followersCount.whereKey("user", equalTo: guestArray.last!)           //注意：这里有改动guestArray.last
        followersCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followers.text = String(count)
            }
        }
        
        //查找Following个数
        let followingsCount = AVQuery(className: "_Followee")
        followingsCount.whereKey("user", equalTo: guestArray.last!)         //注意：这里有改动guestArray.last
        followingsCount.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                header.followings.text = String(count)
            }
        }
        
        //Step 4: 统计数据单击操作
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
    // MARK: 点击图片进入PostVC
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //发送postId到PostViewController中的postId数组中
        postId.append(postIdArray[indexPath.row])
        //将页面转到PostViewController
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostViewController
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 从云端获取访客的帖子信息
    /////////////////////////////////////////////////////////////////////////////////
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last!.username!)             //注意：这里有改动last?.username
        query.limit = postPerPage
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            //查询成功
            if error == nil {
                //清空数组
                self.postIdArray.removeAll(keepingCapacity: false)
                self.pictureArray.removeAll(keepingCapacity: false)
                
                //将查询到的数据添加到数组
                for object in objects! {
                    self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                    self.pictureArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                }
                
                self.collectionView.reloadData()
            }
            else {
                print(error?.localizedDescription ?? "无法获取访客帖子信息！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 返回按钮
    /////////////////////////////////////////////////////////////////////////////////
    @objc func back() {
        //退回到之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从guestArray中移除最后一个AVUser
        if !guestArray.isEmpty {
            guestArray.removeLast()
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
        followers.user = guestArray.last!.username!
        followers.show = "Followers"
        
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 单击”关注“后调用方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func followingsTapAction() {
        //载入FollowViewController的视图
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowVC") as! FollowViewController
        followings.user = guestArray.last!.username!
        followings.show = "Followings"
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 下拉加载更多帖子
    /////////////////////////////////////////////////////////////////////////////////
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            self.loadMorePosts()
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载更多帖子方法
    /////////////////////////////////////////////////////////////////////////////////
    func loadMorePosts() {
        if postPerPage <= pictureArray.count {
            postPerPage = postPerPage + 12
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last!.username!)  //注意：这里有改动current()？.username
            query.limit = postPerPage
            query.addDescendingOrder("createdAt")
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
                    print("loaded + \(self.postPerPage)")
                    self.collectionView.reloadData()
                }
                else {
                    print(error?.localizedDescription ?? "对象查找错误！")
                }
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 刷新页面方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func refresh() {
        self.collectionView.reloadData()
        //停止动画刷新
        self.refresher.endRefreshing()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 十六进制颜色转为UIColor
    /////////////////////////////////////////////////////////////////////////////////
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
