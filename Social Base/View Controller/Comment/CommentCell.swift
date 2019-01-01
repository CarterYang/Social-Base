import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class CommentCell: UITableViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //alignment
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //添加垂直约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[usernameButton]-(-2)-[commentLabel]-5-|", options: [], metrics: nil, views: ["usernameButton": usernameButton, "commentLabel": commentLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[dateLabel]", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[profileImage(40)]", options: [], metrics: nil, views: ["profileImage": profileImage]))
        
        //添加水平约束
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profileImage(40)]-13-[commentLabel]-20-|", options: [], metrics: nil, views: ["profileImage": profileImage, "commentLabel": commentLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[profileImage]-13-[usernameButton]", options: [], metrics: nil, views: ["profileImage": profileImage, "usernameButton": usernameButton]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-10-|", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
