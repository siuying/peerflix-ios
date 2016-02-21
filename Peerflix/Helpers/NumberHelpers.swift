//
//  NumberHelpers.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 22/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation

func formatFileSize(sizeInBytes: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.positiveFormat = "0.#"
    return numberFormatter.stringFromNumber(sizeInBytes/(1024*1024)) ?? ""
}

func formatPercent(value: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.positiveFormat = "0"
    return numberFormatter.stringFromNumber(value * 100.0) ?? ""
}
