//
//  Router.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import UIKit

protocol Router {
    func setup() -> UIWindow

    func openTorrent()
}

class DefaultRouter: Router {
    static let instance = DefaultRouter()
    
    var navController: UINavigationController!
    var torrent: TorrentService

    init(torrent: TorrentService = DefaultTorrentService.instance) {
        self.torrent = torrent
    }

    func setup() -> UIWindow {
        let searchViewController = SearchViewController(torrent: self.torrent, router: self)
        self.navController = UINavigationController(rootViewController: searchViewController)
        self.navController.edgesForExtendedLayout = .None
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = self.navController
        window.makeKeyAndVisible()
        return window
    }

    func openTorrent() {
        self.navController.pushViewController(TorrentViewController(torrent: self.torrent), animated: true)
    }
}