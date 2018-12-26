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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
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
                }
                else {
                    print(error?.localizedDescription)
                }
            })
        }
        else {
            guard user != nil else {return}
            
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followButton.setTitle("关 注", for: .normal)
                    self.followButton.backgroundColor = .lightGray
                }
                else {
                    print(error?.localizedDescription)
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