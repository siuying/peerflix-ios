//
//  JXcore+Extension.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation

extension JXcore {
    // Global JXcore setup

    static func setup() {
        JXcore.useSubThreading()
        JXcore.startEngine("index")
        JXcore.callEventCallback("StartApplication", withParams: ["./dist/app.js"])
        JXcore.addNativeBlock({ (messages, _) -> Void in
            // log error
        }, withName: "OnError")
    }
}