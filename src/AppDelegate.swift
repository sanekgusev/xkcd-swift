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
    
    var window: UIWindow?
    
    var wireframe: MainWireframe!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if let window = window {
            wireframe = AppConfigurationImpl().wireframe
            wireframe.setupInitialUIWithWindow(window)
            window.makeKeyAndVisible()
        }
        
        return true
    }
    
}

