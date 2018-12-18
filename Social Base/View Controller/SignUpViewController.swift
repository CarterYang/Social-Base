import UIKit

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var goToLogInButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //根据需要，设置滚动视图的高度
    var scrollViewHeight : CGFloat = 0
    //获取虚拟键盘的大小
    var keyboard : CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //滚动视图的窗口尺寸
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width
            , height: self.view.frame.height)
        //定义滚动视图的内容视图尺寸与窗口尺寸一样
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        
        //检测键盘出现或消失的状态，用NotificationCenter来实现
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //通过Tap手势让虚拟键盘消失
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }
    
    // MARK: 虚拟键盘出现消失时对Scroll view的操作
    @objc func showKeyboard(notification: Notification) {
        //定义keyboard大小
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboard = keyboardFrame.cgRectValue
        }
        else {
            return
        }
        //当虚拟键盘出现以后，以动画的形式将”scroll view 的实际高度“缩小为”屏幕高度“ - “键盘高度”
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        //当虚拟键盘消失后，将”scroll view 的实际高度“ = ”屏幕高度“
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    //影藏视图中的虚拟键盘
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }

    @IBAction func signUpButtonPressed(_ sender: UIButton) {
    }
    
    //以动画的方式去掉通过modally进来的View controller
    @IBAction func goToLogInButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
