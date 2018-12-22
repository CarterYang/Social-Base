import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

//private let reuseIdentifier = "Cell"

class HomeViewController: UICollectionViewController {

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置导航栏中的title
        self.navigationItem.title = AVUser.current()?.username
    }

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 0
    }

//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//
//        return cell
//    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 当ColloctionViewController要在屏幕上显示附属视图的时候调用的方法
    /////////////////////////////////////////////////////////////////////////////////
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HomeHeaderView
        
        //获取用户信息
        let currentUser = AVUser.current()!
        header.displayName.text = currentUser.object(forKey: "displayName") as? String
        header.bio.text = currentUser.object(forKey: "bio") as? String
        header.bio.sizeToFit() //调整试图大小为包裹所显示文字内容
        
        //获取头像
        let profileImageQuery = currentUser.object(forKey: "profileImage") as? AVFile
        profileImageQuery?.getDataInBackground({ (data: Data?, error: Error?) in
            header.profileImage.image = UIImage(data: data!)
            //print(data!)
        })
        //header.profileImage.image = UIImage(data: (profileImageQuery?.getData())!)
        
        return header
    }
    
}
