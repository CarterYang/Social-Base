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
    
}
