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
    let engine: String
    let query: String
    let torrents: [Torrent]
    let success: Bool

    struct Torrent {
        let name : String
        let size : String
        let seeders : Int
        let leechers : Int
        let URL : Foundation.URL?
    }
    
    static let error = SearchResult(engine: "", query: "", torrents: [], success: false)
}

extension SearchResult: JSONDecodable {
    init(json: JSON) throws {
        self.engine = try json.getString(at: "engine", or: "")
        self.query = try json.getString(at: "query", or: "")
        self.success = try json.getBool(at: "success", or: false)
        self.torrents = try json.getArray(at: "torrents").map(Torrent.init)
    }
}

extension SearchResult.Torrent: JSONDecodable {
    init(json: JSON) throws {
        self.name = try json.getString(at: "name", or: "")
        
        do {
            self.size = try json.getString(at: "size", or: "")
        } catch _ as JSON.Error {
            // todo: change the kickass search engine parser which will return Int size instead of String
            let size = try json.getInt(at: "size", or: 0)
            self.size = formatFileSize(Double(size)) + " M"
        }
        
        self.seeders = try json.getInt(at: "seeders", or: 0)
        self.leechers = try json.getInt(at: "leechers", or: 0)
        self.URL = (try? json.getString(at: "link")).flatMap({ Foundation.URL(string: $0) })
    }
}

extension SearchResult.Torrent: Equatable {
}

func==(lhs: SearchResult.Torrent, rhs: SearchResult.Torrent) -> Bool {
    return lhs.URL == rhs.URL
}
