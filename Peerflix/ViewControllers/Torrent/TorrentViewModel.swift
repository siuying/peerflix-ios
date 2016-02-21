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


func configureTorrentState(torrent: TorrentService, torrentState: Observable<TorrentState>)
    -> (name: Observable<String>, size: Observable<String>, files: Observable<[String]>, downloadSpeed: Observable<String>, downloaded: Observable<String>, playable: Observable<Bool>, URL: Observable<NSURL?>) {
        let torrentFilename = torrent
            .getSelectedTorrent()
            .map({ $0?.name })

        let torrentUrl = torrentState
            .map({ $0.torrentURL?.absoluteString ?? "" })

        let name = Observable.combineLatest(torrentUrl, torrentFilename) { (torrentUrl, torrentFilename) -> String in
                return torrentFilename ?? torrentUrl
            }
            .observeOn(MainScheduler.instance)

        let size = torrentState
            .map({ $0.size ?? 0 })
            .map({ "\(formatFileSize(Double($0))) M" })
            .observeOn(MainScheduler.instance)

        let files = torrentState.map({ $0.files.flatMap({ $0.map({$0.name}) }) }).filterNil()
        let downloadSpeed = torrentState
            .map({ $0.downloadSpeed ?? 0 })
            .map({ "\(formatFileSize(Double($0))) M/s" })
            .observeOn(MainScheduler.instance)
        let downloaded = torrentState
            .map({ ($0.downloaded, $0.size) })
            .map({ (downloaded, size) -> String in
                if let downloaded = downloaded, let size = size {
                    let completion = size == 0 ? 0 : (downloaded * 100.0 / size)
                    return "\(formatFileSize(downloaded))M \(formatPercent(completion))%"
                } else {
                    return ""
                }
            })
            .observeOn(MainScheduler.instance)
        let playable = torrentState
            .map({ $0.status == .Listening || $0.status == .Finished })
            .observeOn(MainScheduler.instance)
        let URL = torrentState
            .map({ $0.videoURL })
            .asObservable()
        
        return (name: name, size: size, files: files, downloadSpeed: downloadSpeed, downloaded: downloaded, playable: playable, URL: URL)
}

class TorrentViewModel {
    let name: Observable<String>
    let size: Observable<String>
    let downloadSpeed: Observable<String>
    let downloaded: Observable<String>
    let files: Observable<[String]>
    let playable: Observable<Bool>
    let URL: Observable<NSURL?>
    let videoURL: Variable<NSURL?>

    private let disposeBag = DisposeBag()

    init(play: Observable<Void>, torrent: TorrentService) {
        let torrentState = torrent.getState().shareReplay(1)

        // setup states
        (self.name, self.size, self.files, self.downloadSpeed, self.downloaded, self.playable, self.URL) = configureTorrentState(torrent, torrentState: torrentState)
        
        // setup video URL
        self.videoURL = Variable(nil)
        torrentState.map({ $0.videoURL })
            .bindTo(videoURL)
            .addDisposableTo(self.disposeBag)
    }
}