//
//  EditViewController.swift
//  Social Base
//
//  Created by Carter on 2018-12-26.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class EditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextView!
    @IBOutlet weak var personalInfoLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    
    
    var sexPicker = UIPickerView()
    let sex = ["男", "女"]
    
    var keyboard = CGRect() //用于储存虚拟键盘的位置和大小，当键盘出现时，需要用它调整滚动视图中Cotent view的垂直偏移量
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sexPicker.dataSource = self
        sexPicker.delegate = self
        sexPicker.backgroundColor = UIColor.groupTableViewBackground
        sexPicker.showsSelectionIndicator = true
        sexTextField.inputView = sexPicker
        
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
        
        //调用布局方法
        alignment()
        
        //获取用户当前信息
        currentInformation()
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 获取用户当前信息方法
    /////////////////////////////////////////////////////////////////////////////////
    func currentInformation() {
        
        let currentUser = AVUser.current()!
        
        usernameLabel.text = currentUser.username
        
        //获取头像
        let profileImageQuery = currentUser.object(forKey: "profileImage") as? AVFile
        profileImageQuery?.getDataInBackground({ (data: Data?, error: Error?) in
            if data == nil {
                print(error?.localizedDescription as Any)
            }
            else {
                self.profileImage.image = UIImage(data: data!)
            }
        })
        
        displayNameTextField.text = currentUser.object(forKey: "displayName") as? String
        bioTextField.text = currentUser.object(forKey: "bio") as? String
        emailTextField.text = currentUser.email
        phoneTextField.text = currentUser.mobilePhoneNumber
        sexTextField.text = currentUser.object(forKey: "sex") as? String
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
    // MARK: Picker设置
    /////////////////////////////////////////////////////////////////////////////////
    //设置Picker组件数量 (UIPickerViewDataSource)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //设置Picker选项数量 (UIPickerViewDataSource)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sex.count
    }

    //设置选项标题 (UIPickerViewDelegate)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sex[row]
    }
    
    //从Picker中得到用户选择的Item (UIPickerViewDelegate)
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sexTextField.text = sex[row]
        self.view.endEditing(true)
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
        //当虚拟键盘出现以后，将滚动视图的内容高度变为控制器视图高度加上键盘高度的一般
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }
    
    @objc func hideKeyboard(notification: Notification) {
        //当虚拟键盘消失后，将scroll view的内容高度值改为0.这样滚动视图会根据实际内容设置大小
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 隐藏虚拟键盘
    /////////////////////////////////////////////////////////////////////////////////
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 保存方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        if !validateEmail(email: emailTextField.text!) {
            alert(error: "Email地址错误", message: "请输入正确的电子邮箱地址！")
            return
        }
        
        let user = AVUser.current()
        user?["displayName"] = displayNameTextField.text
        user?["bio"] = bioTextField.text
        user?.email = emailTextField.text?.lowercased()
        
        if phoneTextField.text!.isEmpty {
            alert(error: "手机号不能为空", message: "请输入您的手机号！")
            return
        }
        else if !validatePhone(phone: phoneTextField.text!) {
            alert(error: "手机号错误", message: "请输入正确的手机号！")
            return
        }
        else {
            user?.mobilePhoneNumber = phoneTextField.text
        }
        
        if sexTextField.text!.isEmpty {
            user?["sex"] = "请在此输入您的性别"
        }
        else {
            user?["sex"] = sexTextField.text
        }
        
        //发送头像数据到服务器
        let profileImageData = UIImage.jpegData(profileImage.image!)(compressionQuality: 0.75)!
        let profileImageFile = AVFile(name: "profileImage.jpg", data: profileImageData)
        user?["profileImage"] = profileImageFile
        
        user?.saveInBackground({ (success: Bool, error: Error!) in
            if success {
                self.view.endEditing(true) //隐藏键盘
                self.dismiss(animated: true, completion: nil) //退出EditVC
            }
            else {
                print(error.localizedDescription)
            }
        })
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
    // MARK: 取消方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 页面布局
    /////////////////////////////////////////////////////////////////////////////////
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        //滚动视图的窗口尺寸
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        usernameLabel.frame = CGRect(x: 20, y: 20, width: width - 40, height: 30)
        profileImage.frame = CGRect(x: width / 2 - 40, y: usernameLabel.frame.origin.y + 40, width: 80, height: 80)
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        
        displayNameTextField.frame = CGRect(x: 20, y: profileImage.frame.origin.y + 100, width: width - 40, height: 30)
        bioTextField.frame = CGRect(x: 20, y: displayNameTextField.frame.origin.y + 40, width: width - 40, height: 90)
        //bio样式设置
        bioTextField.layer.borderWidth = 1
        bioTextField.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        bioTextField.layer.cornerRadius = bioTextField.frame.width / 50
        bioTextField.clipsToBounds = true
        
        personalInfoLabel.frame = CGRect(x: 20, y: bioTextField.frame.origin.y + 110, width: width - 40, height: 30)
        emailTextField.frame = CGRect(x: 20, y: personalInfoLabel.frame.origin.y + 40, width: width - 40, height: 30)
        phoneTextField.frame = CGRect(x: 20, y: emailTextField.frame.origin.y + 40, width: width - 40, height: 30)
        sexTextField.frame = CGRect(x: 20, y: phoneTextField.frame.origin.y + 40, width: width - 40, height: 30)
    }
    
}
