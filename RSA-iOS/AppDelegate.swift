//
//  AppDelegate.swift
//  RSA-iOS
//
//  Created by MacBook on 03/08/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        _setupViewMain()
        
        return true
    }
    
    // MARK: - Private Methods
    private func _setupViewMain() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController: UIViewController = HomeViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

