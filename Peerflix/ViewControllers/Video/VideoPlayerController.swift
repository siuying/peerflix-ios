//
//  VideoPlayerController.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class VideoPlayerController: UIViewController {
    @IBOutlet var mediaControl: MediaControl!
    @IBOutlet var videoView: UIView!
    
    var videoURL: NSURL?
    var services: ServiceFactory = DefaultServiceFactory.instance
    private let disposeBag = DisposeBag()
    private var torrent: TorrentService {
        return self.services.torrent
    }
    
    var player: IJKMediaPlayback!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        let options = IJKFFOptions.optionsByDefault()
        self.player = IJKFFMoviePlayerController(contentURL: self.videoURL, withOptions: options)
        self.player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.player.view.frame = self.videoView.bounds
        self.player.shouldAutoplay = true
        self.videoView.addSubview(self.player.view)
        self.mediaControl.delegatePlayer = self.player
    }
}