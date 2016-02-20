//
//  APIResult.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Freddy

struct APIResult {
    let success: Bool
}

extension APIResult: JSONDecodable {
    init(json: JSON) throws {
        self.success = try json.bool("success", ifNotFound: true) ?? false
    }
}