//
//  TorrentService.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift

protocol TorrentService {
    func getState() -> Observable<TorrentState>

    func search(query: String, service: String) -> Observable<[SearchResult]>

    func selectFile(filename: String)

    func playTorrent(url: String)
    
    func stopTorrent()
}

class DefaultTorrentService: TorrentService {
    func getState() -> Observable<TorrentState> {
        return Observable.empty()
    }
    
    func search(query: String, service: String) -> Observable<[SearchResult]> {
        return Observable.empty()
    }
    
    func selectFile(filename: String) {
    }
    
    func playTorrent(url: String) {
    }
    
    func stopTorrent() {
    }
}