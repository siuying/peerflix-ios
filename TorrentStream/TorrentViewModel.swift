//
//  TorrentViewModel.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift

class TorrentViewModel {
    let name: Observable<String>
    let size: Observable<Double>
    let downloadSpeed: Observable<Double>
    let downloaded: Observable<Double>
    let uploaded: Observable<Double>
    let files: Observable<[String]>
    let playable: Observable<Bool>

    init(torrent: TorrentService) {
        self.name = Observable.just("[HYSUB]Ajin[06][BIG5_MP4][1280X720].mp4")
        self.size = Observable.just(1)
        self.files = Observable.just([])

        self.downloadSpeed = Observable.just(0)
        self.downloaded = Observable.just(0)
        self.uploaded = Observable.just(0)
        self.playable = Observable.just(true)
    }
}