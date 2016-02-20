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
    static let CellID = "SearchResultCellID"
    
    var titleLabel : InfiniteMarqueeLabel!
    var detailLabel : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.layoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)
        stack.spacing = 4
        stack.distribution = .Fill
        stack.alignment = .Leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stack)
        stack.widthAnchor.constraintEqualToAnchor(self.contentView.widthAnchor).active = true
        stack.heightAnchor.constraintEqualToAnchor(self.contentView.heightAnchor).active = true
        stack.topAnchor.constraintEqualToAnchor(self.contentView.topAnchor).active = true
        stack.leftAnchor.constraintEqualToAnchor(self.contentView.leftAnchor).active = true
        
        self.titleLabel = InfiniteMarqueeLabel(frame: CGRectZero)
        self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle3)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(250, forAxis: .Horizontal)
        stack.addArrangedSubview(self.titleLabel)
        
        if UI_USER_INTERFACE_IDIOM() != .TV {
            self.titleLabel.numberOfLines = 0
            self.titleLabel.setContentHuggingPriority(250, forAxis: .Vertical)
            self.titleLabel.heightAnchor.constraintLessThanOrEqualToConstant(80).active = true
        }

        self.detailLabel = UILabel(frame: CGRectZero)
        self.detailLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        self.detailLabel.textColor = UIColor.lightGrayColor()
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailLabel.setContentHuggingPriority(250, forAxis: .Horizontal)
        stack.addArrangedSubview(self.detailLabel)
        
        if UI_USER_INTERFACE_IDIOM() != .TV {
            self.titleLabel.labelize = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.detailLabel.text = ""

        if UI_USER_INTERFACE_IDIOM() == .TV {
            self.titleLabel.labelize = false
        }
    }
    
    func bindViewModel(model: SearchResult.Torrent) {
        self.titleLabel.text = model.name
        self.detailLabel.text = "Size: \(model.size) / Seeders: \(model.seeders) / Leechers: \(model.leechers)"
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
        if UI_USER_INTERFACE_IDIOM() == .TV {
            // scroll text when next focus view is this view
            if context.nextFocusedView == self {
                self.titleLabel.labelize = false
            } else {
                self.titleLabel.labelize = true
            }
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if UI_USER_INTERFACE_IDIOM() == .TV {
            self.titleLabel.labelize = !highlighted            
        }
    }
}