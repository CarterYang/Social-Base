import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class UsersViewController: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //搜索栏
    var searchBar = UISearchBar()
    
    //集合视图UI
    var collectionView: UICollectionView!
    
    //从云端获取信息后保存数据的数组（用于用户搜索）
    var usernameArray = [String]()
    var profileImageArray = [AVFile]()
    
    //储存云端数据（用于collection view显示）
    var postArray = [AVFile]()
    var postIdArray = [String]()
    var postPerPage: Int = 24
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        //实现Search Bar功能
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width - 30
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem      //将search bar作为bar button item显示在nav的左侧
        
        //加载用户搜索
        loadUsers()
        
        // 启动集合视图
        collectionViewLaunch()
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设定Table单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowCell
        
        //隐藏followButton按钮
        cell.followButton.isHidden = true
        
        cell.usernameLabel.text = usernameArray[indexPath.row]
        profileImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.profileImage.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //获取当前用户选择的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! FollowCell
        
        if cell.usernameLabel.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        }
        else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLabel.text!)
            query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestViewController
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载用户
    /////////////////////////////////////////////////////////////////////////////////
    func loadUsers() {
        let usersQuery = AVUser.query()
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.profileImageArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append((object as AnyObject).username!)
                    self.profileImageArray.append((object as AnyObject).value(forKey: "profileImage") as! AVFile)
                }
                
                //刷新表格视图
                self.tableView.reloadData()
            }
            else {
                print(error?.localizedDescription ?? "加载搜索用户出错！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: Search Bar方法
    /////////////////////////////////////////////////////////////////////////////////
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        //userQuery.whereKey("username", contains: searchBar.text!)
        userQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //如果没有搜索到则在displayName中进行搜索
                if objects! .isEmpty {
                    let fullnameQuery = AVUser.query()
                    fullnameQuery.whereKey("displayName", matchesRegex: "(?i)" + searchBar.text!)
                    //userQuery.whereKey("displayName", contains: searchBar.text!)
                    fullnameQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            //清空数组
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.profileImageArray.removeAll(keepingCapacity: false)
                            
                            //查找相关数据
                            for object in objects! {
                                self.usernameArray.append((object as AnyObject).username!)
                                self.profileImageArray.append((object as AnyObject).value(forKey: "profileImage") as! AVFile)
                            }
                            self.tableView.reloadData()
                        }
                    })
                }
                //如果搜索到则将信息载入数组中
                else {
                    //清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.profileImageArray.removeAll(keepingCapacity: false)
                    
                    //查找相关数据
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).username!)
                        self.profileImageArray.append((object as AnyObject).value(forKey: "profileImage") as! AVFile)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadUsers()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //当开始搜索的时候，隐藏集合视图
        collectionView.isHidden = true
        
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //当搜索结束后显示集合视图
        collectionView.isHidden = false
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        loadUsers()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 定义collection view
    /////////////////////////////////////////////////////////////////////////////////
    func collectionViewLaunch() {
        //集合视图的布局
        let layout = UICollectionViewFlowLayout()
        //定义Item的尺寸
        layout.itemSize = CGSize(width: (self.view.frame.width - 2) / 3, height: (self.view.frame.width - 2) / 3)
        //设置滚动方向
        layout.scrollDirection = .vertical
        //定义滚动视图在视图中的位置
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height - 20)
        
        //实例化滚动视图
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        
        //定义collection view中的单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // 载入帖子
        loadPosts()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 定义collection view中的单元格
    /////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postArray.count
    }
    
    //该方法是用来设置同一行 CollectionViewCell 之间的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //该方法是用来设置同一列 CollectionViewCell 之间的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //定义cell中的图片
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(picImg)
        //picImg.contentMode = aspectfill
        postArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                picImg.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription ?? "无法加载数据！")
            }
        }
        
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击单元格调用
    /////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //从postIdArray数组获取当前所单击的帖子的postId，并压入到全局数组postId中
        postId.append(postIdArray[indexPath.row])
        //呈现PostViewController
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostViewController
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载帖子
    /////////////////////////////////////////////////////////////////////////////////
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.limit = postPerPage
        //获取云端Posts数据表中所有帖子数据
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //清空数组
                self.postArray.removeAll(keepingCapacity: false)
                self.postIdArray.removeAll(keepingCapacity: false)
                
                //获取相关数据
                for object in objects! {
                    self.postArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                    self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                }
                self.collectionView.reloadData()
            }
            else {
                print(error?.localizedDescription ?? "无法加载数据！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 下滑Collection View
    /////////////////////////////////////////////////////////////////////////////////
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: loadMore帖子
    /////////////////////////////////////////////////////////////////////////////////
    func loadMore() {
        //如果有更多的帖子需要载入
        if postPerPage <= postArray.count {
            //增加postPerPage的数量
            postPerPage = postPerPage + 24
            
            //载入更多帖子
            let query = AVQuery(className: "Posts")
            query.limit = postPerPage
            query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                if error == nil {
                    //清空数组
                    self.postArray.removeAll(keepingCapacity: false)
                    self.postIdArray.removeAll(keepingCapacity: false)
                    
                    //获取相关数据
                    for object in objects! {
                        self.postArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                        self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                    }
                    self.collectionView.reloadData()
                }
                else {
                    print(error?.localizedDescription ?? "无法加载数据！")
                }
            }
        }
    }
}
