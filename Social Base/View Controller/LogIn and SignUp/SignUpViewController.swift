import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
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
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //滚动视图的窗口尺寸
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
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
        
        //为profile image添加单击手势识别
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImage))
        imgTap.numberOfTapsRequired = 1
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imgTap)
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
        
        //页面布局调整
//        let viewWidth = self.view.frame.width
//        profileImage.frame = CGRect(x: self.view.frame.width / 2 - 40, y: 80, width: 80, height: 80)
//        usernameTextField.frame = CGRect(x: 20, y: profileImage.frame.origin.y + 100, width: viewWidth - 40, height: 30)
//        emailTextField.frame = CGRect(x: 20, y: usernameTextField.frame.origin.y + 50, width: viewWidth - 40, height: 30)
//        passwordTextField.frame = CGRect(x: 20, y: emailTextField.frame.origin.y + 50, width: viewWidth - 40, height: 30)
//        repeatPasswordTextField.frame = CGRect(x: 20, y: passwordTextField.frame.origin.y + 50, width: viewWidth - 40, height: 30)
//        signUpButton.frame = CGRect(x: 20, y: repeatPasswordTextField.frame.origin.y + 50, width: viewWidth - 40, height: 30)
//        goToLogInButton.frame = CGRect(x: 20, y: signUpButton.frame.origin.y + 70, width: viewWidth - 40, height: 30)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 虚拟键盘出现消失时对Scroll view的操作
    /////////////////////////////////////////////////////////////////////////////////
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
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height / 2
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        //当虚拟键盘消失后，将”scroll view 的实际高度“ = ”屏幕高度“
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 隐藏虚拟键盘
    /////////////////////////////////////////////////////////////////////////////////
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 获取照片作为profile image
    /////////////////////////////////////////////////////////////////////////////////
    
    //让用户从相册中选择照片
    @objc func loadImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //把选择好的照片放入profilemage内
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        profileImage.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    //当用户点击取消选择照片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击确认Sign up按钮
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        //隐藏Keyboard
        self.view.endEditing(true)
        
        //当用户名已存在时提示警告信息
        let query = AVQuery(className: "_User")
        query.whereKey("username", equalTo: usernameTextField.text!)
        query.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                print("看这里 \(count)")
                if count != 0 {
                    let alert = UIAlertController(title: "错误", message: "用户名已存在，请更换用户名！", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            else {
                print (error?.localizedDescription ?? "用户名检索发送错误")
            }
        }
        
        //检查Email地址有效性
        if !validateEmail(email: emailTextField.text!) {
            alert(error: "Email地址错误", message: "电子邮箱地址格式错误，请重新输入！")
            return
        }
        
        //当信息不完全时提示警告信息
        if usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || repeatPasswordTextField.text!.isEmpty {
            alert(error: "注意", message: "信息不完整，请重新填写！")
            return
        }

        //判断两次密码输入是否一样
        if passwordTextField.text != repeatPasswordTextField.text {
            alert(error: "注意", message: "两次输入的密码不同，请重新输入！")
            return
        }

        //发送基本数据到服务器
        let user = AVUser()
        user.username = usernameTextField.text
        user.email = emailTextField.text?.lowercased()
        user.password = passwordTextField.text
        //发送头像数据到服务器
        let profileImageData = UIImage.jpegData(profileImage.image!)(compressionQuality: 0.75)!
        let profileImageFile = AVFile(name: "profileImage.jpg", data: profileImageData)
        user["profileImage"] = profileImageFile
        
        //开始注册
        UserDefaults.standard.set(user.username, forKey: "username")
        UserDefaults.standard.synchronize()
        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("成功")
                
                //注册成功后登陆
                AVUser.logInWithUsername(inBackground: user.username!, password: user.password!) { (user: AVUser?, error: Error?) in
                    if let user = user {
                        //记住用户
                        UserDefaults.standard.set(user.username, forKey: "username")
                        UserDefaults.standard.synchronize()

                        //从AppDelegate.swift中调用login方法，让用户直接进入主界面
                        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.login()
                    }
                }
            }
            else {
                print(error?.localizedDescription ?? "注册发生错误！")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 检查Email有效性
    /////////////////////////////////////////////////////////////////////////////////
    func validateEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 检查PhoneNumber有效性
    /////////////////////////////////////////////////////////////////////////////////
    func validatePhone(phone: String) -> Bool {
        let phoneRegex = "0?(13|14|15|18)[0-9]{9}"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 警告消息方法
    /////////////////////////////////////////////////////////////////////////////////
    func alert (error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 关闭Sign up页面
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func goToLogInButtonPressed(_ sender: UIButton) {
        //以动画的方式去掉通过modally进来的View controller
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
