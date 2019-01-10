import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class NewsViewController: UITableViewController {
    
    //储存云端数据到数组
    var usernameArray = [String]()
    var profileImageArray = [AVFile]()
    var typeArray = [String]()
    var dateArray = [Date]()
    var postIdArray = [String]()
    var ownerArray = [String]()

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //动态调整表格的高度
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        //设定导航栏Title
        self.navigationItem.title = "通知"
        
        //从云端载入通知数据
        let query = AVQuery(className: "News")
        query.whereKey("to", equalTo: AVUser.current()!.username!)
        query.limit = 30
        query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                //清空数组
                self.usernameArray.removeAll(keepingCapacity: false)
                self.profileImageArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.postIdArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                for object in objects! as [AnyObject] {
                    self.usernameArray.append((object as AnyObject).value(forKey: "by") as! String)
                    self.profileImageArray.append((object as AnyObject).value(forKey: "profileImage") as! AVFile)
                    self.typeArray.append((object as AnyObject).value(forKey: "type") as! String)
                    self.dateArray.append((object as AnyObject).createdAt!)
                    self.postIdArray.append((object as AnyObject).value(forKey: "postId") as! String)
                    self.ownerArray.append((object as AnyObject).value(forKey: "owner") as! String)
                    
                    object.setObject("yes", forKey: "checked")
                    object.saveEventually()
                }
                //让通知提示条的动画消失
                UIView.animate(withDuration: 1, animations: {
                    icons.alpha = 0
                    corner.alpha = 0
                    dot.alpha = 0
                })
                
                self.tableView.reloadData()
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 配置表格
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 配置单元格
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //从可复用队列中获取单元格对象
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell
        
        //设置usernameButton
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        //设置profileImage
        profileImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.profileImage.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription ?? "加载头像错误！")
            }
        }
        //设置dateLabel
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = Calendar.current.dateComponents(components, from: from, to: now)
        
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
        //设置infoLabel
        if typeArray[indexPath.row] == "mention" {
            cell.infoLabel.text = "@mention了你"
        }
        if typeArray[indexPath.row] == "comment" {
            cell.infoLabel.text = "评论了你的帖子"
        }
        if typeArray[indexPath.row] == "follow" {
            cell.infoLabel.text = "关注了你"
        }
        if typeArray[indexPath.row] == "like" {
            cell.infoLabel.text = "喜欢了你的帖子"
        }
        
        //赋值indexPath给username
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击UsernameButton方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func usernameButtonPressed(_ sender: UIButton) {
        //按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //通过 i 获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! NewsCell
        
        //如果当前用户点击的是自己的Username，返回HomeVC，否则去GuestVC
        if cell.usernameButton.titleLabel?.text == AVUser.current()!.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        }
        else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameButton.titleLabel!.text!)
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
    // MARK: 点击单元格调用方法
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewsCell
        
        //跳转到@mention评论
        if cell.infoLabel.text == "评论了你的帖子" || cell.infoLabel.text == "@mention了你" {
            commentId.append(postIdArray[indexPath.row])
            commentOwner.append(ownerArray[indexPath.row])
            
            //跳转到评论页面
            let comments = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
            self.navigationController?.pushViewController(comments, animated: true)
        }
        
        //跳转到关注人的页面
        if cell.infoLabel.text == "关注了你" {
            //获取关注人的AVUser对象
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameButton.titleLabel!.text!)
            query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    guestArray.append(object as! AVUser)
                    
                    //跳转到访客页面
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestViewController
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            }
        }
        
        //跳转到帖子页面
        if cell.infoLabel.text == "喜欢了你的帖子" {
            postId.append(postIdArray[indexPath.row])
            let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostViewController
            self.navigationController?.pushViewController(post, animated: true)
        }
    }
}
