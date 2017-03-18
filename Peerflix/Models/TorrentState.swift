//
//  TorrentState.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Freddy

struct TorrentState {
    enum Status : String {
        case Init
        case Idle
        case LoadingMetadata
        case Listening
        case Finished
    }
    
    struct File {
        static let FileExtensionRegexp : NSRegularExpression! = try! NSRegularExpression(pattern: "\\.(mp4|avi|divx|wmv|mkv|asf|wma|mov|3gp|rm|flv|ogg|ogm|mp3|pva|es|ps|ts|pva)", options: [.caseInsensitive])
        
        let name : String
        let URL : Foundation.URL?
        let size : Double
        
        init(json: JSON) throws {
            self.name = try json.getString(at: "name")
            self.size = (try? json.getDouble(at: "length", or: 0)) ?? 0
            self.URL = (try? json.getString(at: "url")).flatMap({ Foundation.URL(string: $0) })
        }
        
        // return true if the file looks like a video file
        var isVideo : Bool {
            return File.FileExtensionRegexp.firstMatch(in: name, options: [], range: NSMakeRange(0, (name as NSString).length)) != nil
        }
    }
    
    var torrentURL : URL?
    var videoURL : URL?
    var status = Status.Init
    var filename : String?
    var size : Double?
    var downloaded : Double?
    var uploaded : Double?
    var downloadSpeed : Double?
    var files : [File]?
    
    init() {
    }
    
    init(json: JSON) throws {
        self.torrentURL = (try? json.getString(at: "torrentUrl")).flatMap({ Foundation.URL(string: $0) })
        self.videoURL = (try? json.getString(at: "videoUrl")).flatMap({ Foundation.URL(string: $0) })
        self.status = Status(rawValue: try json.getString(at: "status")) ?? Status.Idle

        self.filename = try? json.getString(at: "filename")

        self.size = try? json.getDouble(at: "size")
        self.downloadSpeed = try? json.getDouble(at: "downloadSpeed")
        self.uploaded = try? json.getDouble(at: "uploaded")
        self.downloaded = try? json.getDouble(at: "downloaded")
        self.files = try json.getArray(at: "files", or: []).map(File.init)
    }
}
