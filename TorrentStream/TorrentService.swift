//
//  TorrentService.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift
import Freddy

protocol TorrentService {
    func getState() -> Observable<TorrentState>

    func search(query: String, service: String) -> Observable<[SearchResult]>

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

        JXcore.useSubThreading()
        JXcore.startEngine("index")
        JXcore.callEventCallback("StartApplication", withParams: ["app.js"])
        JXcore.addNativeBlock({ (messages, _) -> Void in
            // log error
        }, withName: "OnError")
        
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