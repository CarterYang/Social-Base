import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class LogInViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var goToSignUpButton: UIButton!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //通过Tap手势让虚拟键盘消失
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //页面布局调整
//        label.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: 50)
//        usernameTextField.frame = CGRect(x: 10, y: label.frame.origin.y + 100, width: self.view.frame.width - 20, height: 30)
//        passwordTextField.frame = CGRect(x: 10, y: usernameTextField.frame.origin.y + 50, width: self.view.frame.width - 20, height: 30)
//        forgotPasswordButton.frame = CGRect(x: 10, y: passwordTextField.frame.origin.y + 30, width: self.view.frame.width - 20, height: 30)
//        logInButton.frame = CGRect(x: 10, y: forgotPasswordButton.frame.origin.y + 50, width: self.view.frame.width - 20, height: 40)
//        goToSignUpButton.frame = CGRect(x: 10, y: logInButton.frame.origin.y + 70, width: self.view.frame.width - 20, height: 30)
        
        //改变登录按钮为圆角
        logInButton.layer.cornerRadius = logInButton.frame.width / 60
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击确认Log In按钮
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        //隐藏Keyboard
        self.view.endEditing(true)
        
        //当信息不完全时提示警告信息
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            
            //弹出对话框
            let alert = UIAlertController(title: "Attention", message: "Please fill infomation", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //实现用户登录功能
        AVUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user: AVUser?, error: Error?) in
            if error == nil {
                //记住用户
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                //从AppDelegate.swift中调用login方法，让用户直接进入主界面
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 隐藏虚拟键盘
    /////////////////////////////////////////////////////////////////////////////////
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
