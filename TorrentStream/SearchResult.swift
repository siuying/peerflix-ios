//
//  SearchResult.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Freddy

struct SearchResult {
    let name : String
    let size : String
    let seeders : Int
    let leechers : Int
    let URL : NSURL?
    
    init(json: JSON) throws {
        self.name = try json.string("name", ifNotFound: true) ?? ""
        self.size = try json.string("size", ifNotFound: true) ?? ""

        self.seeders = try json.int("seeders", ifNotFound: true) ?? 0
        self.leechers = try json.int("leechers", ifNotFound: true) ?? 0
        self.URL = try json.string("link", ifNotFound: true).flatMap({ NSURL(string: $0) })
        
    }
}