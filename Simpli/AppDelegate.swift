//
//  AppDelegate.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let homeViewController = HomeViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let navHomeVC = UINavigationController(rootViewController: homeViewController)

        window?.rootViewController = navHomeVC

        return true
    }

}

