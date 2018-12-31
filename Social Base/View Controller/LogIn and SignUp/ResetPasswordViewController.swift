import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 重置密码功能
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        //编辑结束时隐藏键盘
        self.view.endEditing(true)
        
        //确定信息正确
        if emailTextField.text!.isEmpty {
            //弹出对话框
            let alert = UIAlertController(title: "Attention", message: "Please fill email address", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        AVUser.requestPasswordResetForEmail(inBackground: emailTextField.text!) { (success: Bool, error: Error?) in
            if success {
                //弹出对话框
                let alert = UIAlertController(title: "Attention", message: "Password reset link has sent to your eamil!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            else {
                print(error?.localizedDescription ?? "重设密码出错！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 取消重置密码功能
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 隐藏虚拟键盘
    /////////////////////////////////////////////////////////////////////////////////
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
