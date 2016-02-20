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
        case Idle
        case LoadingMetadata
        case Listening
        case Finished
    }
    
    struct File {
        static let FileExtensionRegexp : NSRegularExpression! = try! NSRegularExpression(pattern: "\\.(mp4|avi|divx|wmv|mkv|asf|wma|mov|3gp|rm|flv|ogg|ogm|mp3|pva|es|ps|ts|pva)", options: [.CaseInsensitive])
        
        let name : String
        let URL : NSURL?
        let size : Double
        
        init(json: JSON) throws {
            self.name = try json.string("name")
            self.size = try json.double("length")
            self.URL = try json.string("url", ifNotFound: true).flatMap({ NSURL(string: $0) })
        }
        
        // return true if the file looks like a video file
        var isVideo : Bool {
            return File.FileExtensionRegexp.firstMatchInString(name, options: [], range: NSMakeRange(0, (name as NSString).length)) != nil
        }
    }
    
    var torrentURL : NSURL?
    var videoURL : NSURL?
    var status = Status.Idle
    var name : String?
    var filename : String?
    var size : Double?
    var downloaded : Double?
    var uploaded : Double?
    var downloadSpeed : Double?
    var files : [File]?
    
    mutating func updateWithJSON(json: JSON) throws {
        self.videoURL = try json.string("videoUrl", ifNotFound: true).flatMap({ NSURL(string: $0) })
        self.status = Status(rawValue: try json.string("status")) ?? Status.Idle
        self.name = try json.string("name")
        self.filename = try json.string("filename")
        self.size = try json.double("size")
        
        self.downloadSpeed = try json.double("downloadSpeed")
        self.uploaded = try json.double("uploaded")
        self.downloaded = try json.double("downloaded")
        self.files = try json.array("files").map(File.init)
    }
}