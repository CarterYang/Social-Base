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
    @IBOutlet weak var titleLabel: KILabel!
    @IBOutlet weak var postIdLabel: UILabel!
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
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
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[postImage]-0-|", options: [], metrics: nil, views: ["postImage": postImage]))
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[postImage(\(width))]", options: [], metrics: nil, views: ["postImage": postImage]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[commentButton(25)]-15-[likeButton(25)]-5-[likeLabel]", options: [], metrics: nil, views: ["commentButton": commentButton, "likeButton": likeButton, "likeLabel": likeLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[moreButton(25)]-15-|", options: [], metrics: nil, views: ["moreButton": moreButton]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dateLabel]-10-|", options: [], metrics: nil, views: ["dateLabel": dateLabel]))
        
        //改变profile image为圆形
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true //减掉多余的部分
        
        //将likeButton按钮的title文字颜色定位无色
        likeButton.setTitleColor(.clear, for: .normal)
        
        //双击图片添加喜爱
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(likeTap)
    }

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 点击LikeButton方法
    /////////////////////////////////////////////////////////////////////////////////
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        //获取LikeButton的Title
        let title = sender.title(for: .normal)
        //如果当前状态是Unlike，则点击后变为Like
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = postIdLabel.text
            object.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    print("标记为：like！")
                    self.likeButton.setTitle("like", for: .normal)
                    self.likeButton.setBackgroundImage(UIImage(named: "likeSelected.png"), for: .normal)
                    
                    //如果设置为like，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    //单击喜爱按钮后添加到”News“中
                    if self.usernameButton.titleLabel?.text != AVUser.current()?.username {
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["profileImage"] = AVUser.current()?.object(forKey: "profileImage") as! AVFile
                        newsObj["to"] = self.usernameButton.titleLabel?.text
                        newsObj["owner"] = self.usernameButton.titleLabel?.text
                        newsObj["postId"] = self.postIdLabel.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
            }
        }
        //如果当前状态是Like，则点击后变为unLike
        else {
            //搜索Likes中对应记录
            let query = AVQuery(className: "Likes")
            query.whereKey("by", equalTo: AVUser.current()!.username!)
            query.whereKey("to", equalTo: postIdLabel.text!)
            query.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                for object in objects! {
                    //搜索到记录后将其从Likes中删除
                    (object as AnyObject).deleteInBackground({ (success: Bool, error: Error?) in
                        if success {
                            print("删除Like记录，disliked")
                            self.likeButton.setTitle("unlike", for: .normal)
                            self.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: .normal)
                            
                            //如果设置为unlike，则发送通知给表格视图刷新表格
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                            
                            //单击喜爱按钮后到”News“中删除相关信息
                            let newsQuery = AVQuery(className: "News")
                            newsQuery.whereKey("by", equalTo: AVUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernameButton.titleLabel!.text!)
                            newsQuery.whereKey("postId", equalTo: self.postIdLabel.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            
                            newsQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                                if error == nil {
                                    for object in objects! {
                                        (object as AnyObject).deleteEventually()
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 双击图片Like帖子
    /////////////////////////////////////////////////////////////////////////////////
    @objc func likeTapped() {
        //创建一个大大的灰色桃心
        let likePic = UIImageView(image: UIImage(named: "likeSelected.png"))
        likePic.frame.size.width = postImage.frame.width / 1.5
        likePic.frame.size.height = postImage.frame.height / 1.5
        likePic.center = postImage.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        //通过动画隐藏likePic并且让它变小
        UIView.animate(withDuration: 0.4) {
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        //获取LikeButton的Title
        let title = likeButton.title(for: .normal)
        //如果当前状态是Unlike，则点击后变为Like
        if title == "unlike" {
            let object = AVObject(className: "Likes")
            object["by"] = AVUser.current()?.username
            object["to"] = postIdLabel.text
            object.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    print("标记为：like！")
                    self.likeButton.setTitle("like", for: .normal)
                    self.likeButton.setBackgroundImage(UIImage(named: "likeSelected.png"), for: .normal)
                    
                    //如果设置为like，则发送通知给表格视图刷新表格
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    //单击喜爱按钮后添加到”News“中
                    if self.usernameButton.titleLabel?.text != AVUser.current()?.username {
                        let newsObj = AVObject(className: "News")
                        newsObj["by"] = AVUser.current()?.username
                        newsObj["profileImage"] = AVUser.current()?.object(forKey: "profileImage") as! AVFile
                        newsObj["to"] = self.usernameButton.titleLabel?.text
                        newsObj["owner"] = self.usernameButton.titleLabel?.text
                        newsObj["postId"] = self.postIdLabel.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
