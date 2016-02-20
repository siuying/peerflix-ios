//
//  TorrentViewModel.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift

func formatFileSize(sizeInBytes: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.positiveFormat = "0.#"
    return numberFormatter.stringFromNumber(sizeInBytes/(1024*1024)) ?? ""
}

func formatPercent(value: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.positiveFormat = "0"
    return numberFormatter.stringFromNumber(value * 100.0) ?? ""
}

class TorrentViewModel {
    let name: Observable<String>
    let size: Observable<String>

    let downloadSpeed: Observable<String>
    let downloaded: Observable<String>
    let files: Observable<[String]>
    let playable: Observable<Bool>

    init(torrent: TorrentService) {
        let torrentState = torrent.getState()
        

        self.name = torrentState
            .map({ $0.filename ?? $0.torrentURL?.absoluteString ?? "" })
            .observeOn(MainScheduler.instance)

        self.size = Observable.just("")
        self.files = Observable.just([])
        self.downloadSpeed = torrentState
            .map({ $0.downloadSpeed ?? 0 })
            .map({ "\(formatFileSize($0)) M/s" })
            .observeOn(MainScheduler.instance)

        self.downloaded = torrentState
            .map({ ($0.downloaded, $0.size) })
            .map({ (downloaded, size) -> String in
                if let downloaded = downloaded, let size = size {
                    let completion = size == 0 ? 0 : downloaded / size
                    return "\(formatFileSize(completion))M \(formatPercent(completion))"
                } else {
                    return ""
                }
            })
            .observeOn(MainScheduler.instance)

        self.playable = torrentState
            .map({ $0.status == .Listening || $0.status == .Finished })
            .observeOn(MainScheduler.instance)
    }
}