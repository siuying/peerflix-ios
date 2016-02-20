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
    
    var method: Alamofire.Method {
        return .GET
    }
    
    var path: String {
        switch self {
        case .Search:
            return "/search"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: TorrentServiceAPI.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        return mutableURLRequest
    }
}