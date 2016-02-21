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
    func openTorrent()

    func openVideo(URL: NSURL)
}

class DefaultRouter: Router {
    enum Segue: String {
        case OpenTorrent
    }
    
    static let instance = DefaultRouter()

    var navController: UINavigationController!
    var torrent: TorrentService
    var mediaPlayer: IJKMediaPlayback?

    init(torrent: TorrentService = DefaultTorrentService.instance) {
        self.torrent = torrent
    }

    func openTorrent() {
//        guard let searchViewController = self.getRootViewController() as? SearchViewController else {
//            fatalError("must inside search view controller to open torrent")
//        }
//
//        searchViewController.performSegueWithIdentifier(Segue.OpenTorrent.rawValue, sender: nil)
    }
    
    func openVideo(URL: NSURL) {
        print("openVideo \(URL.absoluteString)")
        self.mediaPlayer = IJKAVMoviePlayerController(contentURL: URL)
        self.mediaPlayer!.prepareToPlay()
    }
    
    func getRootViewController() -> UIViewController? {
        let topController = UIApplication.sharedApplication().keyWindow!.rootViewController
        
        guard var controller = topController else {
            return nil
        }
        
        while let vc = controller.presentedViewController {
            controller = vc
        }
        
        return controller
    }
    
}