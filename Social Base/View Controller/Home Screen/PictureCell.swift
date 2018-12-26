//
//  HomePicCellView.swift
//  Social Base
//
//  Created by Carter on 2018-12-21.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 视图初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //页面布局
        let width = UIScreen.main.bounds.width

        //设定单元格中image尺寸
        cellImage.frame = CGRect(x: 0, y: 0, width: (width - 2) / 3, height: (width - 2) / 3)
    }
}
