//
//  FollowersViewController.swift
//  Social Base
//
//  Created by Carter on 2018-12-23.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit

class FollowViewController: UITableViewController {

    var show = String()         //用于在导航栏显示内容
    var user = String()         //用于在返回按钮上显示用户名称
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = show
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    
}
