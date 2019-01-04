import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

var commentId = [String]()
var commentOwner = [String]()

class CommentViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    var refresher = UIRefreshControl()
    
    var tableViewHeight: CGFloat = 0         //用于记录控制器中表格视图高度值
    var commentY: CGFloat = 0                //用于记录评论输入框的Y方向的位置，表格视图的高度变化
    var commentHeight: CGFloat = 0           //用于记录评论输入框的高度
    
    var keyboard = CGRect()                  //用来记录keyboard的大小
    
    //云端信息储存数组
    var usernameArray = [String]()
    var profileImageArray = [AVFile]()
    var commentArray = [String]()
    var dateArray = [Date]()
    
    var page : Int = 15
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation设置
        self.navigationItem.title = "评论"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        
        //开始禁止SendButton按钮
        self.sendButton.isEnabled = false
        
        //向右滑动屏幕返回之前的控制器
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        //检测键盘出现或消失的状态，用NotificationCenter来捕获消息
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //通过Tap手势让虚拟键盘消失
//        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
//        hideTap.numberOfTapsRequired = 1
//        self.view.isUserInteractionEnabled = true
//        self.view.addGestureRecognizer(hideTap)
        
        //self.tableView.backgroundColor = .red
        
        alignment()
        
        loadComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //隐藏底部标签栏
        self.tabBarController?.tabBar.isHidden = true
        //调出键盘
        self.commentTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //让底部标签栏出现
        self.tabBarController?.tabBar.isHidden = false
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设定Table
    /////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        
        cell.usernameButton.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.usernameButton.sizeToFit()
        cell.commentLabel.text = commentArray[indexPath.row]
        profileImageArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.profileImage.image = UIImage(data: data!)
        }
        
        //配置时间
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
        
        cell.usernameButton.layer.setValue(indexPath, forKey: "index")          //为usernameButton添加一个属性变量
        
        return cell
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载Comments
    /////////////////////////////////////////////////////////////////////////////////
    func loadComments() {
        //Step 1: 合计所有评论的数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentId.last!)
        countQuery.countObjectsInBackground { (count: Int, error: Error?) in
            //如果数量大于page数，refresher要起作用
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            //Step 2: 获取最新的self.page数量的评论
            let query = AVQuery(className: "Comments")
            query.whereKey("to", equalTo: commentId.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    //清空数组
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.profileImageArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                        self.profileImageArray.append((object as AnyObject).object(forKey: "profileImage") as! AVFile)
                        self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                        self.dateArray.append((object as AnyObject).createdAt!)
                        
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
                else {
                    print(error?.localizedDescription ?? "无法加载相关评论")
                }
            })
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 加载更多Comments
    /////////////////////////////////////////////////////////////////////////////////
    @objc func loadMore() {
        //Step 1: 合计所有的评论数量
        let countQuery = AVQuery(className: "Comments")
        countQuery.whereKey("to", equalTo: commentId.last!)
        countQuery.countObjectsInBackground { (count: Int, error: Error?) in
            //让refresher停止刷新动画
            self.refresher.endRefreshing()
            
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            //Step 2: 载入更多的评论
            if self.page < count {
                self.page = self.page + 15
                
                //从云端查询page个记录
                let query = AVQuery(className: "Comments")
                query.whereKey("to", equalTo: commentId.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                    if error == nil {
                        //清空数组
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.profileImageArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append((object as AnyObject).object(forKey: "username") as! String)
                            self.profileImageArray.append((object as AnyObject).object(forKey: "profileImage") as! AVFile)
                            self.commentArray.append((object as AnyObject).object(forKey: "comment") as! String)
                            self.dateArray.append((object as AnyObject).createdAt!)
                        }
                        self.tableView.reloadData()
                        //self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: .bottom, animated: false)
                    }
                    else {
                        print(error?.localizedDescription ?? "无法加载相关评论")
                    }
                })
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设置单元格可编辑
    /////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //获取用户所滑动的单元格对象
        let cell = tableView.cellForRow(at: indexPath) as! CommentCell

        //动作 1: 删除行为
        let delete = UITableViewRowAction(style: .normal, title: "删除") { (action: UITableViewRowAction, indexPath: IndexPath) in
            //Step 1: 从云端删除评论
            let commentQuery = AVQuery(className: "Comments")
            commentQuery.whereKey("to", equalTo: commentId.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentLabel.text!)
            commentQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if error == nil {
                    //找到相关记录
                    for object in objects! {
                        (object as AnyObject).deleteEventually()
                    }
                }
                else {
                    print(error?.localizedDescription ?? "无法删除评论")
                }
            })

            //Step 2: 从TableView删除单元格
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.profileImageArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)

            //Step 3: 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }

        //动作 2: Address
        let address = UITableViewRowAction(style: .normal, title: " @ ") { (action: UITableViewRowAction, indexPath: IndexPath) in
            //在TextView中加入Address
            self.commentTextField.text = "\(self.commentTextField.text + "@" + self.usernameArray[indexPath.row] + " ")"
            //让发送按钮生效
            self.sendButton.isEnabled = true
            //关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }

        //动作 3: 投诉评论
        let complain = UITableViewRowAction(style: .normal, title: "举报") { (action: UITableViewRowAction, indexPath: IndexPath) in
            //发送投诉到云端
            let complainObj = AVObject(className: "Complain")
            complainObj["by"] = AVUser.current()?.username
            complainObj["post"] = commentId.last
            complainObj["to"] = cell.commentLabel.text
            complainObj["owner"] = cell.usernameButton.titleLabel?.text
            complainObj.saveInBackground({ (success: Bool, error: Error?) in
                if success {
                    self.alert(error: "举报信息已经提交！", message: "感谢您的支持，我们会关注您提交的举报！")
                    print("举报已经处理")
                }
                else {
                    //self.alert(error: "错误", message: error?.localizedDescription ?? "无法处理投诉")
                    print(error?.localizedDescription ?? "无法处理投诉")
                }
            })

            //Step 3: 关闭单元格的编辑状态
            self.tableView.setEditing(false, animated: true)
        }

        //为按钮设置颜色
        delete.backgroundColor = .red
        address.backgroundColor = self.hexStringToUIColor(hex: "#4A4A48")
        complain.backgroundColor = self.hexStringToUIColor(hex: "#4A4A48")

        //为按钮设置图片(这里用图片来创建颜色)
        //delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete")!)
        //address.backgroundColor = UIColor(patternImage: UIImage(named: "address")!)
        //complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain")!)

        //根据情况加载按钮
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
            return [delete, address]                                //评论是自己的
        }
        else if commentOwner.last == AVUser.current()?.username {
            return [delete, address, complain]                      //帖子是自己的
        }
        else {
            return [address, complain]                              //评论是别人的
        }
    }

    
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 虚拟键盘出现消失时对Scroll view的操作
    /////////////////////////////////////////////////////////////////////////////////
    @objc func keyboardWillShow(notification: Notification) {
        //获取键盘的大小
        let rect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]!) as! NSValue
        keyboard = rect.cgRectValue
        //键盘出现调整高度
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height
            self.commentTextField.frame.origin.y = self.commentY - self.keyboard.height
            self.sendButton.frame.origin.y = self.commentTextField.frame.origin.y
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        //键盘消失时调整高度
        UIView.animate(withDuration: 0.4) {
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTextField.frame.origin.y = self.commentY
            self.sendButton.frame.origin.y = self.commentTextField.frame.origin.y
        }
    }
    
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击输入框调用方法
    /////////////////////////////////////////////////////////////////////////////////
    func textViewDidChange(_ textView: UITextView) {
        //如果没有输入信息则禁止发送按钮
        let spacing = CharacterSet.whitespacesAndNewlines
        if !commentTextField.text.trimmingCharacters(in: spacing).isEmpty {
            sendButton.isEnabled = true
        }
        else {
            sendButton.isEnabled = false
        }
        
        //增加输入框高度
        if textView.contentSize.height > textView.frame.height && textView.frame.height < 130 {
            let difference = textView.contentSize.height - textView.frame.height
            //调整输入框大小
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            //将tableView的下边缘上移
            if tableView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        //减少输入框高度
        else if textView.contentSize.height < textView.frame.height {
            let difference = textView.frame.height - textView.contentSize.height
            //调整输入框大小
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            //将tableView的下边缘下移
            if tableView.contentSize.height + keyboard.height + commentY >= tableView.frame.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 返回按钮方法
    /////////////////////////////////////////////////////////////////////////////////
    @objc func back() {
        //退回到之前
        self.navigationController?.popViewController(animated: true)
        //从commentId中移除评论的id
        if !commentId.isEmpty {
            commentId.removeLast()
        }
        //从commentOwner中清除评论者
        if !commentOwner.isEmpty {
            commentOwner.removeLast()
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 页面布局
    /////////////////////////////////////////////////////////////////////////////////
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        tableView.estimatedRowHeight = width / 5.33
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height / 1.096 - self.navigationController!.navigationBar.frame.height - 20)
        //commentTextField.frame = CGRect(x: 10, y: tableView.frame.height + height / 56.8, width: width / 1.306, height: 33)
        commentTextField.frame = CGRect(x: 10, y: tableView.frame.height + 25, width: width / 1.306, height: 33)
        sendButton.frame = CGRect(x: commentTextField.frame.origin.x + commentTextField.frame.width + width / 32, y: commentTextField.frame.origin.y, width: width - (commentTextField.frame.origin.x + commentTextField.frame.width) - width / 32 * 2, height: commentTextField.frame.height)
        
        //评论输入框圆角效果
        commentTextField.layer.cornerRadius = commentTextField.frame.width / 50
        
        //l记录关键位置的初始值
        tableViewHeight = tableView.frame.height
        commentHeight = commentTextField.frame.height
        commentY = commentTextField.frame.origin.y
        
        commentTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func usernameButtonPressed(_ sender: UIButton) {
        //获取按钮的index
        let i = sender.layer.value(forKey: "index") as! IndexPath
        //通过i获取到用户所单击的单元格
        let cell = tableView.cellForRow(at: i) as! CommentCell
        
        //如果点击的是自己的Username，则调回HomeVC，否则进入GuestVC
        if cell.usernameButton.titleLabel?.text == AVUser.current()?.username {
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
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        //Step 1: 在表格视图中添加最新的评论
        usernameArray.append(AVUser.current()!.username!)
        profileImageArray.append(AVUser.current()?.object(forKey: "profileImage") as! AVFile)
        dateArray.append(Date())
        commentArray.append(commentTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        tableView.reloadData()
        
        //Step 2:发送评论到云端储存
        let commentObj = AVObject(className: "Comments")
        commentObj["to"] = commentId.last
        commentObj["username"] = AVUser.current()?.username
        commentObj["profileImage"] = AVUser.current()?.object(forKey: "profileImage")
        commentObj["comment"] = commentTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj.saveEventually()     //在后台线程提交数据到云端，但不一定是马上提交，而是由AVOSloud SDK决定什么时候提交，从而提高程序的性能和效率
        //Scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(item: commentArray.count - 1, section: 0), at: .bottom, animated: false)
        
        //Step 3: 发送数据后重新设定视图表格
        commentTextField.text = ""
        commentTextField.frame.size.height = commentHeight
        commentTextField.frame.origin.y = sendButton.frame.origin.y
        tableView.frame.size.height = tableViewHeight - keyboard.height - commentTextField.frame.height + commentHeight
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
