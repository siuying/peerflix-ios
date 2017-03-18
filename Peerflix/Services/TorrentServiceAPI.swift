//
//  TorrentServiceAPI.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Alamofire

enum TorrentServiceAPI: URLRequestConvertible {
    static let baseURLString = "http://localhost:9870"
    
    enum SearchEngine : String {
        case Extra      = "extra"
        case PirateBay  = "piratebay"
        case Kickass    = "kickass"
        case Nyaa       = "nyaa"
        case DMHY       = "dmhy"
        
        var title : String {
            switch self {
            case .DMHY:
                return "DMHY"
            case .Extra:
                return "Extra"
            case .Nyaa:
                return "Nyaa"
            case .PirateBay:
                return "Pirate Bay"
            case .Kickass:
                return "Kickass"
            }
        }
    }
    
    case search(String, SearchEngine)
    case play(String)
    case stop()
    case select(String)
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .search:
            return "/search"
        case .play:
            return "/torrent/play"
        case .stop:
            return "/torrent/stop"
        case .select:
            return "/torrent/select"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: TorrentServiceAPI.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .search(let query, let engine):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["query": query, "engine": engine.rawValue])
                .0
        case .play(let url):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["url": url])
                .0
        case .select(let filename):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["filename": filename])
                .0            
        default:
            return mutableURLRequest
        }
    }
}
