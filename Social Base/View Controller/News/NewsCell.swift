import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class NewsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //添加约束
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profileImage(30)]-10-[usernameButton]-10-[infoLabel]-10-[dateLabel]", options: [], metrics: nil, views: ["profileImage": profileImage, "usernameButton": usernameButton, "infoLabel": infoLabel, "dateLabel": dateLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profileImage(30)]-10-[usernameButton]-10-[infoLabel]", options: [], metrics: nil, views: ["profileImage": profileImage, "usernameButton": usernameButton, "infoLabel": infoLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-10-|", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[profileImage(30)]-10-|", options: [], metrics: nil, views: ["profileImage": profileImage]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[usernameButton(30)]", options: [], metrics: nil, views: ["usernameButton": usernameButton]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[infoLabel(30)]", options: [], metrics: nil, views: ["infoLabel": infoLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[dateLabel(30)]", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        
        //头像变圆
        self.profileImage.layer.cornerRadius = profileImage.frame.width / 2
        self.profileImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
