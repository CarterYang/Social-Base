//
//  FollowersViewController.swift
//  Social Base
//
//  Created by Carter on 2018-12-23.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class FollowViewController: UITableViewController {

    var show = String()         //用于在导航栏显示内容
    var user = String()         //用于在返回按钮上显示用户名称
    
    var followArray = [AVUser]()
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table的格式
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        self.navigationItem.title = show
        
        //确认显示”followers“还是”followings“
        if show == "Followers" {
            loadFollowers()
        }
        else if show == "Followings"{
            loadFollowings()
        }
        else {
            return
        }
        
        tableView.reloadData()
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: GuestVC返回刷新页面
    /////////////////////////////////////////////////////////////////////////////////
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 设定Table
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followArray.count
    }
    
    override func tableView(_ tableview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowCell
        
        //Cell信息
        cell.usernameLabel.text = followArray[indexPath.row].username
        let profileImage = followArray[indexPath.row].object(forKey: "profileImage") as! AVFile
        
        //下载头像
        profileImage.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.profileImage.image = UIImage(data: data!)
            }
            else {
                print(error?.localizedDescription)
            }
        }
        
        //区分“已关注”和“未关注”的状态
        let query = followArray[indexPath.row].followeeQuery()
        query.whereKey("user", equalTo: AVUser.current()!)
        query.whereKey("followee", equalTo: followArray[indexPath.row])
        //查看是否关注
        query.countObjectsInBackground { (count: Int, error: Error?) in
            if error == nil {
                if count == 0 {
                    cell.followButton.setTitle("关 注", for: .normal)
                    cell.followButton.backgroundColor = .lightGray
                }
                else {
                    cell.followButton.setTitle("已关注", for: .normal)
                    cell.followButton.backgroundColor = self.hexStringToUIColor(hex: "#26BAEE")
                }
            }
        }
        //将关注对象传递给FollowCell
        cell.user = followArray[indexPath.row]
        //为当前用户隐藏关注按钮
        if cell.usernameLabel.text == AVUser.current()?.username {
            cell.followButton.isHidden = true
        }
        
        return cell
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 当选中对象时调用
    /////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //通过indexPath获取用户所单击的单元格内的用户
        let cell = tableView.cellForRow(at: indexPath) as! FollowCell
        
        //单击单元格，进入HomeVC或者GuestVC
        if cell.usernameLabel.text == AVUser.current()?.username {
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        }
        else {
            guestArray.append(followArray[indexPath.row])
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 载入Followers信息
    /////////////////////////////////////////////////////////////////////////////////
    func loadFollowers() {
        guestArray.last?.getFollowers({ (followers: [Any]?, error: Error?) in
            if error == nil && followers != nil {
                self.followArray = followers! as! [AVUser]
                //刷新，否则Array中的值为零，因为一直在后台运行
                self.tableView.reloadData()
            }
            else {
                print(error?.localizedDescription)
            }
        })
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 载入Followings信息
    /////////////////////////////////////////////////////////////////////////////////
    func loadFollowings() {
        guestArray.last?.getFollowees({ (followings: [Any]?, error: Error?) in
            if error == nil && followings != nil {
                self.followArray = followings! as! [AVUser]
                //刷新，否则Array中的值为零，因为一直在后台运行
                self.tableView.reloadData()
            }
            else {
                print(error?.localizedDescription)
            }
        })
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
