//
//  SingleScreenAppDelegate.swift
//  ExampleApp
//
//  Created by Michael Eisel on 1/16/20.
//  Copyright © 2020 Michael Eisel. All rights reserved.
//

import UIKit

@UIApplicationMain
class SingleScreenAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = OtherViewController()
        return true
    }
}

