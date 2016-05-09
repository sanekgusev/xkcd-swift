//
//  UINavigationController+RootViewController.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import UIKit

extension UINavigationController {
    var rootViewController: UIViewController? {
        get {
            return viewControllers.first
        }
        set {
            var viewControllers = self.viewControllers
            if viewControllers.isEmpty {
                if let newValue = newValue {
                    viewControllers.append(newValue)
                }
            }
            else {
                if let newValue = newValue {
                    viewControllers[0] = newValue
                }
                else {
                    viewControllers.removeFirst()
                }
            }
            self.viewControllers = viewControllers
        }
    }
}
