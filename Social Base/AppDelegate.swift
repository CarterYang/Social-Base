import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting
import SwipeCellKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        AVOSCloud.setApplicationId("3fgqRlL3RuFPyJfhATCHX5c2-gzGzoHsz", clientKey: "btuOvI5YFtsij0EGoo1EK35K")
        
        //跟踪应用打开情况
        //AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        window?.backgroundColor = .white
        
        //如果有登录信息直接跳转页面
        login()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func login() {
        //获取UserDefaults中z储存的用户信息
        let username: String? = UserDefaults.standard.string(forKey: "username")
        
        //如果用户不是空的
        if username != nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            window?.rootViewController = myTabBar
        }
        
//        AVUser.current()?.follow("5c1c28f59f545400706a733c") {(success: Bool, error: Error?) in
//            if success {
//                print("关注成功")
//            }
//            else {
//                print("关注失败")
//            }
//        }
    }

}

