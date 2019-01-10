//
//  FollowersCell.swift
//  Social Base
//
//  Created by Carter on 2018-12-23.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class FollowCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var user: AVUser!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 视图初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func awakeFromNib() {
        super.awakeFromNib()

        //Cell布局
        let width = UIScreen.main.bounds.width
        
        profileImage.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameLabel.frame = CGRect(x: profileImage.frame.width + 20, y: profileImage.center.y - 15, width: width / 3.2, height: 30)
        followButton.frame = CGRect(x: width - width / 3.5 - 20, y: profileImage.center.y - 15, width: width / 3.5, height: 30)
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
        
        //改变关注按钮为圆角
        followButton.layer.cornerRadius = followButton.frame.width / 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    ////////////////////////////////////////////////////////////////////////////////
    // MARK: 添加关注与取消关注
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func followButtonPressed(_ sender: UIButton) {
        let title = followButton.title(for: .normal)
        
        if title == "关 注" {
            guard user != nil else {return}
            
            AVUser.current()?.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followButton.setTitle("已关注", for: .normal)
                    self.followButton.backgroundColor = self.hexStringToUIColor(hex: "#26BAEE")
                    
                    //发送关注通知到云端
                    let newsObj = AVObject(className: "News")
                    newsObj["by"] = AVUser.current()?.username
                    newsObj["profileImage"] = AVUser.current()?.object(forKey: "profileImage") as! AVFile
                    newsObj["to"] = self.usernameLabel.text
                    newsObj["owner"] = ""
                    newsObj["postId"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                }
                else {
                    print(error?.localizedDescription ?? "无法更改关注状态！")
                }
            })
        }
        else {
            guard user != nil else {return}
            
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followButton.setTitle("关 注", for: .normal)
                    self.followButton.backgroundColor = .lightGray
                    
                    //删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("by", equalTo: AVUser.current()!.username!)
                    newsQuery.whereKey("to", equalTo: self.usernameLabel.text!)
                    newsQuery.whereKey("type", equalTo: "follow")
                    newsQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            for object in objects! {
                                (object as AnyObject).deleteEventually()
                            }
                        }
                    })
                }
                else {
                    print(error?.localizedDescription ?? "无法更改关注状态！")
                }
            })
        }
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
