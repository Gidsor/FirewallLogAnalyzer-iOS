//
//  MainTabBarController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 22/04/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(tabBarController: self)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.duration = 0.4
        tabBar.subviews[item.tag + 1].layer.add(animation, forKey: "Scale")
    }
    
    private func configure(tabBarController: UITabBarController) {
        tabBarController.delegate = self
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            for tabBarItem in tabBarController.tabBar.items! {
                tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
        default:
            break
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
