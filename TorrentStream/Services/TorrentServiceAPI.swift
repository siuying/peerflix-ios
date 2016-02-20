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
    
    case Search(String, SearchEngine)
    case Play(String)
    case Stop()
    case Select(String)
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .Search:
            return "/search"
        case .Play:
            return "/torrent/play"
        case .Stop:
            return "/torrent/stop"
        case .Select:
            return "/torrent/select"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: TorrentServiceAPI.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .Search(let query, let engine):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["query": query, "engine": engine.rawValue])
                .0
        case .Play(let url):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["url": url])
                .0
        case .Select(let filename):
            return Alamofire.ParameterEncoding
                .URL
                .encode(mutableURLRequest, parameters: ["filename": filename])
                .0            
        default:
            return mutableURLRequest
        }
    }
}