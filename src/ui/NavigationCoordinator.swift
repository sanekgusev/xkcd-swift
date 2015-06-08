//
//  NavigationCoordinator.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 1/17/15.
//
//

import UIKit

extension NavigationCoordinator {
    var rootViewController : UIViewController {
        return self.splitViewController
    }
    
    class var sharedCoordinator: NavigationCoordinator {
        struct Static {
            static let instance = NavigationCoordinator()
        }
        return Static.instance
    }
}

class NavigationCoordinator : NSObject,
UISplitViewControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var splitViewController : UISplitViewController =
        self.createSplitViewController()
    private lazy var masterNavigationController : UINavigationController =
        self.createMasterNavigationController()
    private lazy var detailNavigationController : UINavigationController =
        self.createDetailNavigationController()
    private lazy var masterViewController : UIViewController =
        self.createMasterViewController()
    private lazy var detailViewController : UIViewController =
        self.createDetailViewController()
    
    private override init() {
        super.init()
    }
    
    private func createSplitViewController() -> UISplitViewController {
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [self.masterNavigationController,
            self.detailNavigationController]
        return splitViewController
    }
    
    private func createMasterNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self.masterViewController)
        return navigationController
    }
    
    private func createDetailNavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self.detailViewController)
        return navigationController
    }
    
    private func createMasterViewController() -> UIViewController {
        return UIViewController()
    }
    
    private func createDetailViewController() -> UIViewController {
        return UIViewController()
    }
}
