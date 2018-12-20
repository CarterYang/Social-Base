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
        
        //为profile image添加单击手势识别
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImage))
        imgTap.numberOfTapsRequired = 1
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imgTap)
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
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
        
        //当信息不完全时提示警告信息
        if usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || repeatPasswordTextField.text!.isEmpty {
            
            //弹出对话框
            let alert = UIAlertController(title: "Attention", message: "Please fill infomation", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //判断两次密码输入是否一样
        if passwordTextField.text != repeatPasswordTextField.text {
            
            //弹出对话框
            let alert = UIAlertController(title: "Attention", message: "Password not same", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //发送基本数据到服务器
        let user = AVUser()
        user.username = usernameTextField.text?.lowercased()
        user.email = emailTextField.text?.lowercased()
        user.password = passwordTextField.text
        //发送头像数据到服务器
        let profileImageData = UIImage.jpegData(profileImage.image!)(compressionQuality: 0.75)!
        let profileImageFile = AVFile(name: "profileImage.jpg", data: profileImageData)
        user["profileImage"] = profileImageFile
        //开始注册
        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("成功")
            }
            else {
                print("失败")
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 关闭Sign up页面
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func goToLogInButtonPressed(_ sender: UIButton) {
        //以动画的方式去掉通过modally进来的View controller
        self.dismiss(animated: true, completion: nil)
    }
}
