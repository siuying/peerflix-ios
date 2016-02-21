//
//  ServiceFactory.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation

protocol ServiceFactory {
    var router: Router { get }
    var torrent: TorrentService { get }
}

class DefaultServiceFactory: ServiceFactory {
    static let instance = DefaultServiceFactory()

    let router: Router = DefaultRouter.instance
    let torrent: TorrentService = DefaultTorrentService.instance
}