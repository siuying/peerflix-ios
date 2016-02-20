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

    func search(query: String, engine: String) -> Observable<SearchResult>

    func selectFile(filename: String)

    func playTorrent(url: String)
    
    func stopTorrent()
}

class DefaultTorrentService: TorrentService {
    static let instance = DefaultTorrentService()

    var state: Observable<TorrentState>!
    var error: Observable<ErrorType?>!
    
    init() {
    }

    func setup() {
        let state: Variable<TorrentState> = Variable(TorrentState())
        let error: Variable<ErrorType?> = Variable(nil)
        self.state = state.asObservable().shareReplay(1)
        self.error = error.asObservable().shareReplay(1)

        JXcore.setup()
        JXcore.addNativeBlock({ (params, callbackId) -> Void in
            if params.count < 1 {
                print("unexpected params count: \(params)")
                return
            }
            
            guard let jsonStr = params[0] as? String else {
                print("unexpected params: \(params)")
                return
            }
            
            do {
                let json = try JSON(data: jsonStr.dataUsingEncoding(NSUTF8StringEncoding)!)
                state.value = try TorrentState(json: json)
                
            } catch let e {
                print("JSON parsing error: \(e)")
                error.value = e
            }
        }, withName: "UpdateTorrentState")
    }
    
    func getState() -> Observable<TorrentState> {
        return state
    }
    
    func search(query: String, engine: TorrentServiceAPI.SearchEngine) -> Observable<SearchResult> {
        return Alamofire.request(TorrentServiceAPI.Search(query, engine))
            .rx_reponseJSON()
            .map { (json) -> SearchResult in
                return try json.decode(type: SearchResult.self)
            }
    }
    
    func selectFile(filename: String) {
    }
    
    func playTorrent(url: String) {
    }
    
    func stopTorrent() {
    }
}