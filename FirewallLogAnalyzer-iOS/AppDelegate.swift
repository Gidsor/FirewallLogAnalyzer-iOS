//
//  AppDelegate.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 25/03/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if UserSettings.server != nil && UserSettings.password != nil {
            setRootViewController(storyboardName: "Main", viewControlellerIdentifier: "MainTabBarController")
        }  else {
            setRootViewController(storyboardName: "Main", viewControlellerIdentifier: "ConnectServerViewController")
        }
        return true
    }
    
    func setRootViewController(storyboardName: String, viewControlellerIdentifier: String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControlellerIdentifier)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
}

