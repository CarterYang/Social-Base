import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

//全局变量
var postId = [String]()

class PostViewController: UITableViewController {
    
    var profileImageArray = [AVFile]()
    var usernameArray = [String]()
    var dateArray = [Date]()
    var postImageArray = [AVFile]()
    var postIdArray = [String]()
    var titleArray = [String]()

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //定义返回按钮
        self.navigationItem.hidesBackButton = true
        //let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        
        //向右滑动屏幕返回之前的控制器
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        //动态单元格高度设置
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 550
        tableView.separatorStyle = .singleLine
        
        self.navigationItem.title = "照片"
        
        //对指定pistId帖子的查询
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("postId", equalTo: postId.last!)
        postQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            //清空数组
            self.profileImageArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.postImageArray.removeAll(keepingCapacity: false)
            self.postIdArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in objects! {
                self.profileImageArray.append((object as AnyObject).value(forKey: "profileImage") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.dateArray.append((object as AnyObject).createdAt!)
                self.postImageArray.append((object as AnyObject).value(forKey: "picture") as! AVFile)
                self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "postTitle") as! String)
            }
            self.tableView.reloadData()
        }
        
        //当收到like通知后，刷新页面
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name.init(rawValue: "liked"), object: nil)
    }
    
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        postImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
//            let postHeight = UIImage(data: data!)!.size.height
//
//            //tableView.rowHeight = postHeight + 120
//            var aaa = postHeight + 120
//
//        }
//        return 550
//    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设定Table
    /////////////////////////////////////////////////////////////////////////////////
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //从表格视图的可复用队列中获取单元格对象
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        //关注信息
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameButton.sizeToFit()     //根据文字内容去调整自身大小
        cell.postIdLabel.text = postIdArray[indexPath.row]
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.titleLabel.sizeToFit()         //根据文字内容去调整自身大小
        
        //配置头像
        profileImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.profileImage.image = UIImage(data: data!)
        }
        
        //配置帖子
        postImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            //self.tableView.beginUpdates()
            
//            let postWidth = Float(UIImage(data: data!)!.size.width)
//            let postHeight = Float(UIImage(data: data!)!.size.height)
//            let postRatio = postHeight / postWidth
//            cell.postImage.frame.size.width = UIScreen.main.bounds.width
//            cell.postImage.frame.size.height = CGFloat(Float(UIScreen.main.bounds.width) * postRatio)
            
            cell.postImage.image = UIImage(data: data!)
            //cell.postImage.frame.size.width = (UIImage(data: data!)?.size.width)!
            //cell.postImage.frame.size.height = (UIImage(data: data!)?.size.height)!
            //cell.postImage.sizeToFit()     //根据文字内容去调整自身大小
            
            //cell.postImage.sizeToFit()
            
            //self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            //self.tableView.endUpdates()
            //self.tableView.reloadData()
        }
        
        //配置时间
        let createdTime = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: createdTime, to: now)
        
        if difference.second! <= 0 {
            cell.dateLabel.text = "现在"
        }
        
        if difference.second! > 0 && difference.minute! <= 0 {
            cell.dateLabel.text = "\(difference.second!)秒"
        }
        
        if difference.minute! > 0 && difference.hour! <= 0 {
            cell.dateLabel.text = "\(difference.minute!)分"
        }
        
        if difference.hour! > 0 && difference.day! <= 0 {
            cell.dateLabel.text = "\(difference.hour!)小时"
        }
        
        if difference.day! > 0 && difference.weekOfMonth! <= 0 {
            cell.dateLabel.text = "\(difference.day!)天"
        }
        
        if difference.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(difference.weekOfMonth!)周"
        }

        //根据用户是否喜欢设置LikeButton按钮
        let didLike = AVQuery(className: "Likes")
        didLike.whereKey("by", equalTo: AVUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.postIdLabel.text!)
        didLike.countObjectsInBackground { (count: Int, error: Error?) in
            if count == 0 {
                cell.likeButton.setTitle("unlike", for: .normal)
                cell.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
            }
            else {
                cell.likeButton.setTitle("like", for: .normal)
                cell.likeButton.setBackgroundImage(UIImage(named: "likeSelected.png"), for: .normal)
            }
        }
        //计算本帖子的喜爱总数
        let countLikes = AVQuery(className: "Likes")
        countLikes.whereKey("to", equalTo: cell.postIdLabel.text!)
        countLikes.countObjectsInBackground { (count: Int, error: Error?) in
            cell.likeLabel.text = "\(count)"
        }
        
        //当 @mentions 被点击
        //当用户点击@连接后执行闭包代码，首先传递进三个参数：
        //1. label代表用户所单击label对象
        //2. handle代表所单击的@mention
        //3. range是handle在label中的位置范围
        cell.titleLabel.userHandleLinkTapHandler = {label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())     //去掉首字符@
            
            if mention == AVUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                self.navigationController?.pushViewController(home, animated: true)
            }
            else {
                let query = AVUser.query()
                query.whereKey("username", equalTo: mention)
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if let object = objects?.last {
                        guestArray.append(object as! AVUser)
                        let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestViewController
                        self.navigationController?.pushViewController(guest, animated: true)
                    }
                    //用户不存在
                    else {
                        let alert = UIAlertController(title: "\(mention)", message: "该用户不存在或已经被删除！", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        //当 #hashtag 被点击
        //当用户点击#连接后执行闭包代码，首先传递进三个参数：
        //1. label代表用户所单击label文本
        //2. handle代表所单击的#hashtag链接
        //3. range是handle在label中的位置范围
        cell.titleLabel.hashtagLinkTapHandler = {label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())     //去掉首字符#
            hashtag.append(mention.lowercased())      //将hashtag添加到全局数组hashtag中
            
            let hashVC = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsViewController
            self.navigationController?.pushViewController(hashVC, animated: true)
        }
        
        //将indexPath赋值给usernameButton的layer属性的自定义变量
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        //将indexPath赋值给commentButton的layer属性的自定义变量
        cell.commentButton.layer.setValue(indexPath, forKey: "index")
        //将indexPath赋值给moreButton的layer属性的自定义变量
        cell.moreButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 刷新页面
    /////////////////////////////////////////////////////////////////////////////////
    @objc func refresh() {
        self.tableView.reloadData()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 返回按钮方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func back() {
        //退回到之前
        self.navigationController?.popViewController(animated: true)
        //从postId中移除当前帖子的id
        if !postId.isEmpty {
            postId.removeLast()
        }
//        postRatio = 1
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击UsernameButton方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func usernameButtonPressed(_ sender: UIButton) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //通过 i 获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //如果当前用户点击的是自己的Username，返回HomeVC，否则去GuestVC
        if cell.usernameButton.titleLabel?.text == AVUser.current()!.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        }
        else {
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击CommentButton方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //通过 i 获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //发送相关数据到CommentVC中的全局变量
        commentId.append(cell.postIdLabel.text!)
        commentOwner.append(cell.usernameButton.titleLabel!.text!)
        
        //通过导航控制器到CommentVC
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击More方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        //删除操作
        let delete = UIAlertAction(title: "删除", style: .default) { (UIAlertAction) in
            //Step 1: 从数组中删除相应的数据
            self.usernameArray.remove(at: i.row)
            self.profileImageArray.remove(at: i.row)
            self.postImageArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.postIdArray.remove(at: i.row)
            
            //Step 2: 删除云端的记录
            let postQuery = AVQuery(className: "Posts")
            postQuery.whereKey("postId", equalTo: cell.postIdLabel.text!)
            postQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                            if success {
                                //发送通知到rootViewController更新帖子 (HomeVC)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                //销毁当前控制器
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            else {
                                print(error?.localizedDescription ?? "删除帖子出错！")
                            }
                        })
                    }
                }
                else {
                    print(error?.localizedDescription ?? "找不到相关帖子！")
                }
            })
            
            //Step 3: 删除帖子的Like记录
            let likeQuery = AVQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: cell.postIdLabel.text!)
            likeQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            //Step 4: 删除帖子相关的评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: cell.postIdLabel.text!)
            commentQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
            
            //Step 5: 删除帖子相关的Hashtag
            let hashtagQuery = AVQuery(className: "Hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.postIdLabel.text!)
            hashtagQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
            })
        }
        
        //投诉操作
        let complain = UIAlertAction(title: "投诉", style: .default) { (UIAlertAction) in
            //发送投诉到云端的Complain数据表
            let complainObject = AVObject(className: "Complain")
            complainObject["by"] = AVUser.current()?.username
            complainObject["post"] = cell.postIdLabel.text
            complainObject["to"] = cell.titleLabel.text
            complainObject["owner"] = cell.usernameButton.titleLabel?.text
            complainObject.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.alert(error: "投诉信息已提交成功", message: "感谢您的支持，我们将关注您提交的投诉信息！")
                }
                else {
                    self.alert(error: "错误", message: error?.localizedDescription ?? "投诉提交出错！")
                }
            })
        }
        
        // 取消操作
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        // 创建菜单控制器
        let menu = UIAlertController(title: "菜单选项", message: nil, preferredStyle: .actionSheet)
        
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        }
        else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        //显示菜单
        self.present(menu, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 警告消息
    /////////////////////////////////////////////////////////////////////////////////
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
