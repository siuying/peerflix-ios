//
//  TorrentService.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Freddy
import Alamofire

protocol TorrentService {
    func getState() -> Observable<TorrentState>

    func getSelectedTorrent() -> Observable<SearchResult.Torrent?>

    func getSearchEngine() -> Observable<TorrentServiceAPI.SearchEngine>

    func search(_ query: String) -> Observable<SearchResult>

    func selectFile(_ filename: String) -> Observable<APIResult>

    func playTorrent(_ torrent: SearchResult.Torrent) -> Observable<APIResult>

    func stopTorrent() -> Observable<APIResult>
    
    func setSearchEngine(_ engine: TorrentServiceAPI.SearchEngine)
}

class DefaultTorrentService: TorrentService {
    static let instance = DefaultTorrentService()

    var selectedTorrent: Variable<SearchResult.Torrent?>
    var engine: Variable<TorrentServiceAPI.SearchEngine>
    var state: Observable<TorrentState>
    var error: Observable<Error?>
    
    init() {
        let state: Variable<TorrentState> = Variable(TorrentState())
        let error: Variable<Error?> = Variable(nil)
        self.engine = Variable(TorrentServiceAPI.SearchEngine.PirateBay)
        self.state = state.asObservable().shareReplay(1)
        self.error = error.asObservable().shareReplay(1)
        self.selectedTorrent = Variable(nil)

        JXcore.setup()
        JXcore.addNativeBlock({ (params, callbackId) -> Void in
            guard let params = params else {
                print("unexpected, params is nil")
                return
            }

            if params.count < 1 {
                print("unexpected params count: \(params)")
                return
            }
            
            guard let jsonStr = params[0] as? String else {
                print("unexpected params: \(params)")
                return
            }
            
            do {
                if let data = jsonStr.data(using: .utf8) {
                    let json = try JSON(data: data)
                    state.value = try TorrentState(json: json)
                }
            } catch let e {
                print("JSON parsing error: \(e)")
                error.value = e
            }
        }, withName: "UpdateTorrentState")
    }
    
    func getState() -> Observable<TorrentState> {
        return state
    }
    
    func getSelectedTorrent() -> Observable<SearchResult.Torrent?> {
        return self.selectedTorrent.asObservable()
    }
    
    func getSearchEngine() -> Observable<TorrentServiceAPI.SearchEngine> {
        return self.engine.asObservable()
    }
    
    func search(_ query: String) -> Observable<SearchResult> {
        print("search: \(query), engine: \(self.engine.value.rawValue)")
        return Alamofire.request(TorrentServiceAPI.search(query, self.engine.value))
            .rx.responseJSON()
            .map { (json) -> SearchResult in
                return try json.decode(type: SearchResult.self)
            }
    }
    
    func selectFile(_ filename: String) -> Observable<APIResult> {
        return Alamofire.request(TorrentServiceAPI.select(filename))
            .rx.responseJSON()
            .map({ try $0.decode(type: APIResult.self) })
    }
    
    func playTorrent(_ torrent: SearchResult.Torrent) -> Observable<APIResult> {
        guard let URL = torrent.URL else {
            return Observable.empty()
        }

        self.selectedTorrent.value = torrent
        return Alamofire.request(TorrentServiceAPI.play(URL.absoluteString))
            .rx.responseJSON()
            .map({ try $0.decode(type: APIResult.self) })
    }
    
    func stopTorrent() -> Observable<APIResult> {
        return Alamofire.request(TorrentServiceAPI.stop())
            .rx.responseJSON()
            .map({ try $0.decode(type: APIResult.self) })
    }
    
    func setSearchEngine(_ engine: TorrentServiceAPI.SearchEngine) {
        self.engine.value = engine
    }
}
