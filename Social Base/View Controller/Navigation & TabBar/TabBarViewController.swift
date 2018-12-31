import UIKit

class TabBarViewController: UITabBarController {

    /////////////////////////////////////////////////////////////////////////////////
    // MARK: 屏幕初始化
    /////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        //每个Item的文字颜色
        self.tabBar.tintColor = .white
        //标签栏的背景色
        self.tabBar.barTintColor = UIColor(red: 37.0/255.0, green: 39.0/255.0, blue: 42.0/255.0, alpha: 1)
        
        self.tabBar.isTranslucent = false
    }

}
