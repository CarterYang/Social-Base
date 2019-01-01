import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

var commentId = [String]()
var commentOwner = [String]()

class CommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!

    
    var refresher = UIRefreshControl()
    
    var tableViewHeight: CGFloat = 0         //用于记录控制器中表格视图高度值
    var commentY: CGFloat = 0                //用于记录评论输入框的Y方向的位置，表格视图的高度变化
    var commentHeight: CGFloat = 0           //用于记录评论输入框的高度
    
    var keyboard = CGRect()                  //用来记录keyboard的大小
    
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
    }
}
