//
//  HomeHeaderView.swift
//  Social Base
//
//  Created by Carter on 2018-12-21.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class HomeHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!                   //头像
    @IBOutlet weak var displayName: UILabel!                        //显示名称
    @IBOutlet weak var bio: UILabel!                                //简介
    @IBOutlet weak var posts: UILabel!                              //帖子数
    @IBOutlet weak var followers: UILabel!                          //关注者数
    @IBOutlet weak var followings: UILabel!                         //关注数
    @IBOutlet weak var postsTitle: UILabel!                         //帖子名称
    @IBOutlet weak var followersTitle: UILabel!                     //关注者名称
    @IBOutlet weak var followingsTitle: UILabel!                    //关注名称
    @IBOutlet weak var editProfile: UIButton!                       //编辑资料
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 从GuestVC中单击关注按钮
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func followButtonPressed(_ sender: UIButton) {
        let title = editProfile.title(for: .normal)
        
        //获取当前访客对象
        let user = guestArray.last
        
        if title == "关 注" {
            guard let user = user else {return}
            
            AVUser.current()?.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.editProfile.setTitle("已关注", for: .normal)
                    self.editProfile.backgroundColor = self.hexStringToUIColor(hex: "#26BAEE")
                }
                else {
                    print(error?.localizedDescription ?? "无法关注对象")
                }
            })
        }
        else {
            guard let user = user else {return}
            
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.editProfile.setTitle("关 注", for: .normal)
                    self.editProfile.backgroundColor = .lightGray
                }
                else {
                    print(error?.localizedDescription ?? "无法取消关注对象")
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
