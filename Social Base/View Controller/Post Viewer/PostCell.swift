import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width

        //关闭UI层面的Constraint
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        postImage.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        postIdLabel.translatesAutoresizingMaskIntoConstraints = false

//        let postHeight = width
//        let bbb = Float(aaa)
//        postImage.frame = CGRect(x: 0, y: 50, width: width, height: (postImage.image?.size.height)!)

//        postImage.frame.size.width = (postImage.image?.size.width)!
//        postImage.frame.size.height = (postImage.image?.size.height)!

        //添加垂直方向Constraint
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[profileImage(30)]-10-[postImage(\(width))]-5-[commentButton(25)]-5-[titleLabel]-5-|", options: [], metrics: nil, views: ["profileImage": profileImage, "postImage": postImage, "commentButton": commentButton, "titleLabel": titleLabel]))
        //垂直方向距离顶部10个点是usernameButton
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[usernameButton]", options: [], metrics: nil, views: ["usernameButton": usernameButton]))
        //垂直方向距离postImage10个点是likeButton，likeButton高度是30
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[postImage]-5-[likeButton(25)]", options: [], metrics: nil, views: ["postImage": postImage, "likeButton": likeButton]))
        //垂直方向距离顶部10个点是dateLabel
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[dateLabel]", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        //垂直方向距离commentButton下方5个点是titleLabel，再下面5个点是单元格底部
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[commentButton(30)]-5-[titleLabel(50)]-5-|", options: [], metrics: nil, views: ["commentButton": commentButton, "titleLabel": titleLabel]))
        //垂直方向距离postImage底部5个点是moreButton，moreButton高度为30
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[postImage]-5-[moreButton(25)]", options: [], metrics: nil, views: ["postImage": postImage, "moreButton": moreButton]))
        //垂直方向距离postImage底部10个点是likeLabel，高度为默认值
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[postImage]-7.5-[likeLabel]", options: [], metrics: nil, views: ["postImage": postImage, "likeLabel": likeLabel]))

        //水平方向Constraint
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[profileImage(30)]-10-[usernameButton]", options: [], metrics: nil, views: ["profileImage": profileImage, "usernameButton": usernameButton]))
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[postImage]-0-|", options: [], metrics: nil, views: ["postImage": postImage]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[postImage(\(width))]", options: [], metrics: nil, views: ["postImage": postImage]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[commentButton(25)]-15-[likeButton(25)]-5-[likeLabel]", options: [], metrics: nil, views: ["commentButton": commentButton, "likeButton": likeButton, "likeLabel": likeLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[moreButton(25)]-15-|", options: [], metrics: nil, views: ["moreButton": moreButton]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-10-|", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
