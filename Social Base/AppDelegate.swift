import UIKit
import AVOSCloud
import AVOSCloudIM
import AVOSCloudCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        AVOSCloud.setApplicationId("3fgqRlL3RuFPyJfhATCHX5c2-gzGzoHsz", clientKey: "btuOvI5YFtsij0EGoo1EK35K")
        
        //跟踪应用打开情况
        //AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
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


}

