import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

//private let reuseIdentifier = "Cell"

var hashtag = [String]()

class HashtagsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    //刷新控件,负责滚动视图拉拽的刷新动画
    var refresher = UIRefreshControl()
    
    //每次从云端下载照片的数量
    var postPerPage: Int = 18           //24
    
    //从云端获取记录后，存储数据的数组
    var picArray = [AVFile]()           //储存帖子照片
    var postIdArray = [String]()        //储存帖子的postId
    var filterArray = [String]()        //用于储存过滤出来符合条件的帖子
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.alwaysBounceVertical = true             //让collection view永远在垂直方向上滚动
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        //定义导航栏中的返回按钮
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
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
        loadHashtags()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设置单元格布局
    /////////////////////////////////////////////////////////////////////////////////
    //该方法是用来设置 CollectionViewCell 的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (self.view.frame.width - 2) / 3, height: (self.view.frame.width - 2) / 3)
        return size
    }

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
        
        //return pictureArray.count
        return picArray.count
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 配置单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //定义Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        //从PictureArray中提取图片
        picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.cellImage.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription ?? "无法从PicArray中提取图片！")
            }
        }
        
        return cell
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
    // MARK: 通过hashtag加载相关帖子
    /////////////////////////////////////////////////////////////////////////////////
    func loadHashtags() {
        //Step 1: 获取与Hashtag相关的帖子
        let hashtagQuery = AVQuery(className: "Hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //清空filterArray数组
                self.filterArray.removeAll(keepingCapacity: false)
                
                //储存相关的帖子到filterArray数组
                for object in objects! {
                    self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                }
                
                //Step 2: 通过filterArray的id找出相关帖子
                let query = AVQuery(className: "Posts")
                query.whereKey("postId", containedIn: self.filterArray)
                query.limit = self.postPerPage
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if error == nil {
                        //清空数组
                        self.picArray.removeAll(keepingCapacity: false)
                        self.postIdArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.picArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                            self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                        }
                        
                        //reload界面
                        self.collectionView.reloadData()
                        self.refresher.endRefreshing()
                    }
                    else {
                        print(error?.localizedDescription ?? "无法加载与hashtag相关帖子！")
                    }
                })
            }
            else {
                print(error?.localizedDescription ?? "无法加载hashtag！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: CollectionView下拉加载更多帖子
    /////////////////////////////////////////////////////////////////////////////////
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //当用户拖拽collectionView的垂直偏移量大于contentSize高度的1/3时加载更多帖子
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            self.loadMorePosts()
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载更多帖子方法
    /////////////////////////////////////////////////////////////////////////////////
    func loadMorePosts() {
        //如果服务器端的帖子大于默认显示数量
        if postPerPage <= postIdArray.count {
            postPerPage = postPerPage + 12
            
            //Step 1: 获取与HashTag相关的帖子
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                if error == nil {
                    //清空filterArray数组
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    //储存相关的帖子到filterArray数组
                    for object in objects! {
                        self.filterArray.append((object as AnyObject).value(forKey: "to") as! String)
                    }
                    
                    //Step 2: 通过filterArray的id找出相关帖子
                    let query = AVQuery(className: "Posts")
                    query.whereKey("postId", containedIn: self.filterArray)
                    query.limit = self.postPerPage
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            //清空数组
                            self.picArray.removeAll(keepingCapacity: false)
                            self.postIdArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.picArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                                self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                            }
                            
                            //reload界面
                            self.collectionView.reloadData()
                            //self.refresher.endRefreshing()      //取消因为是让collectionView在用户拖拽了1/3时刷新，所以并没有在refresher控件生效时被执行
                        }
                        else {
                            print(error?.localizedDescription ?? "无法加载与hashtag相关帖子！")
                        }
                    })
                }
                else {
                    print(error?.localizedDescription ?? "无法加载hashtag！")
                }
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 返回按钮
    /////////////////////////////////////////////////////////////////////////////////
    @objc func back() {
        //退回到之前的控制器
        self.navigationController?.popViewController(animated: true)
        
        //从hashtag中移除最后一个标签
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 刷新页面方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func refresh() {
        //self.collectionView.reloadData()
        loadHashtags()
        //停止动画刷新
        self.refresher.endRefreshing()
    }
}
