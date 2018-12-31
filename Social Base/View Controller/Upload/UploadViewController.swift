import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pictureField: UIImageView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var publishButton: UIButton!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //默认状态下禁用”发布“按钮
        publishButton.isEnabled = false
        publishButton.backgroundColor = self.hexStringToUIColor(hex: "#535962")
        
        //为pictureField添加单击手势识别
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        pictureTap.numberOfTapsRequired = 1
        pictureField.isUserInteractionEnabled = true
        pictureField.addGestureRecognizer(pictureTap)
        
        //通过Tap手势让虚拟键盘消失
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //隐藏移除按钮
        //removeButton.isHidden = true
        
        //让页面回到原始状态
        //pictureField.image =
        pictureField.image = UIImage(named: "Placeholder-image.png")
        textField.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alignment()
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 从相册获取照片
    /////////////////////////////////////////////////////////////////////////////////
    //让用户从相册中选择照片
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    //把选择好的照片放入pictureImage内
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        pictureField.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //显示移除按钮
        //removeButton.isHidden = false
        
        //解禁Publish button
        publishButton.isEnabled = true
        publishButton.backgroundColor = UIColor(red: 52.0 / 255.0, green: 169.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        
        //实现第二次单击放大图片
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomPicture))
        zoomTap.numberOfTapsRequired = 1
        pictureField.isUserInteractionEnabled = true
        pictureField.addGestureRecognizer(zoomTap)
    }
    
    //当用户点击取消选择照片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 放大或缩小图片
    /////////////////////////////////////////////////////////////////////////////////
    @objc func zoomPicture() {
        //放大后的Image View的位置
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.navigationController!.navigationBar.frame.height * 1.5, width: self.view.frame.width, height: self.view.frame.width)
        
        //Image View还原到初始位置
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)
        
        //如果pictureImage是初始大小
        if pictureField.frame == unzoomed {
            UIView.animate(withDuration: 0.4) {
                self.pictureField.frame = zoomed
                self.view.backgroundColor = UIColor.black
                self.textField.alpha = 0
                self.removeButton.alpha = 0
                self.publishButton.alpha = 0
            }
        }
        //如果pictureImage是放大后的状态
        else {
            UIView.animate(withDuration: 0.4) {
                self.pictureField.frame = unzoomed
                self.view.backgroundColor = UIColor.white
                self.textField.alpha = 1
                self.removeButton.alpha = 1
                self.publishButton.alpha = 1
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 移除照片
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        self.viewDidLoad()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 发布图片
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func publishButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["profileImage"] = AVUser.current()?.value(forKey: "profileImage") as! AVFile
        object["postId"] = "\(AVUser.current()!.username! ) \(NSUUID().uuidString)"
        
        if textField.text.isEmpty {
            object["postTitle"] = ""
        }
        else {
            object["postTitle"] = textField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)  //去掉两端的空格和换行
        }
        
        let pictureData = UIImage.jpegData(pictureField.image!)(compressionQuality: 0.75)!
        let pictureFile = AVFile(name: "post.jpg", data: pictureData)
        object["picture"] = pictureFile
        
        //上传数据到服务器
        object.saveInBackground { (success: Bool, error: Error?) in
            if error == nil {
                //发送上传通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                //将TabBar控制器中索引值为0的自控制器显示在手机屏幕上(回到HomeVC)
                self.tabBarController?.selectedIndex = 0
                //reset页面
                self.viewDidLoad()
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 页面布局
    /////////////////////////////////////////////////////////////////////////////////
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        pictureField.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        removeButton.frame = CGRect(x: 15, y: pictureField.frame.origin.y + width / 4.5 + 10, width: width / 4.5, height: 30)
        textField.frame = CGRect(x: pictureField.frame.width + 25, y: pictureField.frame.origin.y, width: width - textField.frame.origin.x - 15, height: pictureField.frame.height + 40)
        publishButton.frame = CGRect(x: 15, y: height - width / 8 - 10, width: width - 30, height: width / 8)
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
    

    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 隐藏虚拟键盘
    /////////////////////////////////////////////////////////////////////////////////
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
