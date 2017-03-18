//
//  NumberHelpers.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 22/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation

func formatFileSize(_ sizeInBytes: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.positiveFormat = "0.#"
    return numberFormatter.string(from: NSNumber(floatLiteral: (sizeInBytes/(1024*1024)))) ?? ""
}

func formatPercent(_ value: Double) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.positiveFormat = "0"
    return numberFormatter.string(from: NSNumber(floatLiteral: value * 100.0)) ?? ""
}
