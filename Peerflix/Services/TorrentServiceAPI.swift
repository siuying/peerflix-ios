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
    
    var method: Alamofire.HTTPMethod {
        return .get
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
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: TorrentServiceAPI.baseURLString)!.appendingPathComponent(path)
        let parameters: Parameters = {
            switch self {
            case .search(let query, let engine):
                return ["query": query, "engine": engine.rawValue]
            case .play(let url):
                return ["url": url]
            case .select(let filename):
                return ["filename": filename]
            default:
                return [:]
            }
        }()

        let request = try URLRequest(url: url, method: .get)
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
