//
//  AppDelegate.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 1/17/15.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    @objc internal lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window!.rootViewController = NavigationCoordinator.sharedCoordinator.rootViewController
        window!.makeKeyAndVisible()
        return true
    }

}

