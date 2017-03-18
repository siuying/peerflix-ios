//
//  AppDelegate.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 18/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DefaultWireframe.instance.setup()
        return true
    }
}

