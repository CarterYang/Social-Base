//
//  RootPageViewController.swift
//  Social Base
//
//  Created by Carter on 2018-12-17.
//  Copyright © 2018 Carter. All rights reserved.
//

import UIKit

class RootPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //把不同的ViewController放入Array中
    let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraVC")
    let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
    let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageVC")
    
    var viewControllerArray = [UIViewController]()
    
    // MARK: view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        //指定第一个View conroller
        viewControllerArray = [cameraVC, homeVC, messageVC]
        setViewControllers([viewControllerArray[1]], direction: .forward, animated: true, completion: nil)
    }

    // MARK: 向前翻页
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let index = viewControllerArray.index(of: viewController) {
            if index > 0 {
                return viewControllerArray[index - 1]
            }
        }
        
        return nil
    }
    
    // MARK: 向后翻页
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let index = viewControllerArray.index(of: viewController) {
            if index < viewControllerArray.count - 1 {
                return viewControllerArray[index + 1]
            }
        }
        
        return nil
    }
    
}
