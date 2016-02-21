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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DefaultWireframe.instance.setup()
        return true
    }
}

