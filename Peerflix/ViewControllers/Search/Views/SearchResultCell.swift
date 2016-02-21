//
//  SearchResultCell.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import UIKit
import MarqueeLabel

class InfiniteMarqueeLabel : MarqueeLabel {
    override func labelReturnedToHome(finished: Bool) {
        self.holdScrolling = false
        super.restartLabel()
    }
}

class SearchResultCell : UITableViewCell {
    static let CellID = "SearchResultCell"
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var detailLabel : UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.detailLabel.text = ""
    }
    
    func bindViewModel(model: SearchResult.Torrent) {
        self.titleLabel.text = model.name
        self.detailLabel.text = "Size: \(model.size) / Seeders: \(model.seeders) / Leechers: \(model.leechers)"
    }
}