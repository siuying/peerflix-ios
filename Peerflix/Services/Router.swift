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
    static let instance = DefaultRouter()
    
    var navController: UINavigationController!
    var torrent: TorrentService
    var mediaPlayer: IJKMediaPlayback?

    init(torrent: TorrentService = DefaultTorrentService.instance) {
        self.torrent = torrent
    }

    func openTorrent() {
        self.navController.pushViewController(TorrentViewController(torrent: self.torrent, router: self), animated: true)
    }
    
    func openVideo(URL: NSURL) {
        print("openVideo \(URL.absoluteString)")
        self.mediaPlayer = IJKAVMoviePlayerController(contentURL: URL)
        self.mediaPlayer!.prepareToPlay()
    }
}