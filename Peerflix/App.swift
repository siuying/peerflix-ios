//
//  App.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation

class App {
    static func isSimulator() -> Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #else
            return false
        #endif
    }
    
    static func temporaryDirectory() -> String {
        return NSTemporaryDirectory().stringByAppendingString("Peerflix")
    }
    
    static func prepareTemporaryDirectory() {
        let dir = temporaryDirectory()
        let manager = NSFileManager.defaultManager()
        do {
            try manager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            print("error delete temp folder: \(e)")
        }
    }
    
    static func cleanTemporaryDirectory() {
        let manager = NSFileManager.defaultManager()
        do {
            try manager.removeItemAtPath(self.temporaryDirectory())
        } catch let e {
            print("error delete temp folder: \(e)")
        }
    }
}