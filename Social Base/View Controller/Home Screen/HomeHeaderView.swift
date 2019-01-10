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
    // MARK: 视图初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //页面布局
        let width = UIScreen.main.bounds.width
        
        //让button变成圆角
        editProfile.layer.cornerRadius = editProfile.frame.width / 50
        
        //头像布局
        profileImage.frame = CGRect(x: width / 16, y: 15, width: width / 4, height: width / 4)
        //统计数据布局
        posts.frame = CGRect(x: width / 2.5, y: profileImage.frame.origin.y, width: 50, height: 30)
        followers.frame = CGRect(x: width / 1.6, y: profileImage.frame.origin.y, width: 50, height: 30)
        followings.frame = CGRect(x: width / 1.2, y: profileImage.frame.origin.y, width: 50, height: 30)
        //统计数据label布局
        postsTitle.center = CGPoint(x: posts.center.x, y: posts.center.y + 20)
        followersTitle.center = CGPoint(x: followers.center.x, y: followers.center.y + 20)
        followingsTitle.center = CGPoint(x: followings.center.x, y: followings.center.y + 20)
        //编辑资料布局布局
        editProfile.frame = CGRect(x: postsTitle.frame.origin.x, y: postsTitle.center.y + 25, width: followings.frame.origin.x - posts.frame.origin.x + 40, height: 30)
        //信息布局
        displayName.frame = CGRect(x: profileImage.frame.origin.x, y: profileImage.frame.origin.y + profileImage.frame.height, width: width - 30, height: 30)
        bio.frame = CGRect(x: displayName.frame.origin.x, y: displayName.frame.origin.y + 30, width: width - 30, height: 30)
        
    }
    
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
                    
                    //发送关注通知到云端
                    let newsObj = AVObject(className: "News")
                    newsObj["by"] = AVUser.current()?.username
                    newsObj["profileImage"] = AVUser.current()?.object(forKey: "profileImage") as! AVFile
                    newsObj["to"] = guestArray.last?.username
                    newsObj["owner"] = ""
                    newsObj["postId"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
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
                    
                    //删除关注通知
                    let newsQuery = AVQuery(className: "News")
                    newsQuery.whereKey("by", equalTo: AVUser.current()!.username!)
                    newsQuery.whereKey("to", equalTo: guestArray.last!.username!)
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
