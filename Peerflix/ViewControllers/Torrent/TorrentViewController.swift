//
//  TorrentViewController.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TorrentViewController: UIViewController {
    var viewModel: TorrentViewModel!
    var torrent: TorrentService!
    let disposeBag = DisposeBag()

    var titleLabel : UILabel!
    var downloadedLabel : UILabel!
    var downloadSpeedLabel : UILabel!
    var playButton : UIButton!

    init(torrent: TorrentService) {
        super.init(nibName: nil, bundle: nil)
        self.torrent = torrent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = .None

        let stack = UIStackView()
        stack.axis = .Vertical
        stack.spacing = 4.0
        stack.layoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsetsMake(10, 8, 10, 8)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .Fill
        stack.alignment = .Fill
        self.view.addSubview(stack)
        
        stack.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        stack.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        stack.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.topAnchor).active = true
        stack.bottomAnchor.constraintEqualToAnchor(self.bottomLayoutGuide.bottomAnchor).active = true

        self.titleLabel = UILabel()
        self.titleLabel.numberOfLines = 0
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        self.titleLabel.text = "Loading"
        self.titleLabel.setContentHuggingPriority(750, forAxis: .Vertical)
        stack.addArrangedSubview(self.titleLabel)
        self.titleLabel.heightAnchor.constraintLessThanOrEqualToConstant(200).active = true

        self.downloadedLabel = UILabel()
        self.downloadedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.downloadedLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        self.downloadedLabel.textColor = UIColor.lightGrayColor()
        self.downloadedLabel.text = "30M"
        self.downloadedLabel.setContentHuggingPriority(751, forAxis: .Vertical)
        stack.addArrangedSubview(self.downloadedLabel)

        self.downloadSpeedLabel = UILabel()
        self.downloadSpeedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.downloadSpeedLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        self.downloadSpeedLabel.textColor = UIColor.lightGrayColor()
        self.downloadSpeedLabel.text = "100K"
        self.downloadSpeedLabel.setContentHuggingPriority(751, forAxis: .Vertical)
        stack.addArrangedSubview(self.downloadSpeedLabel)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(250, forAxis: .Vertical)
        stack.addArrangedSubview(spacer)

        self.playButton = UIButton(type: .System)
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.setTitle("Play", forState: .Normal)
        self.playButton.contentHorizontalAlignment = .Center
        self.playButton.setContentHuggingPriority(751, forAxis: .Vertical)
        stack.addArrangedSubview(self.playButton)

        self.viewModel = TorrentViewModel(torrent: self.torrent)
        self.viewModel.name
            .bindTo(self.titleLabel.rx_text)
            .addDisposableTo(self.disposeBag)

        self.viewModel.downloaded
            .bindTo(self.downloadedLabel.rx_text)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel.downloadSpeed
            .bindTo(self.downloadSpeedLabel.rx_text)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel.playable
            .bindTo(self.playButton.rx_enabled)
            .addDisposableTo(self.disposeBag)
   }
}