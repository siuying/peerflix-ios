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
        options.setPlayerOptionIntValue(1, forKey: "videotoolbox")
        options.setFormatOptionIntValue(1, forKey: "auto_convert")
        self.player = IJKFFMoviePlayerController(contentURL: self.videoURL, withOptions: options)
        self.player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.player.view.frame = self.videoView.bounds
        self.player.shouldAutoplay = true
        self.player.scalingMode = .AspectFit
        self.player.allowsMediaAirPlay = true
        self.videoView.addSubview(self.player.view)
        self.mediaControl.delegatePlayer = self.player
        
        let player = self.player
        let mediacontrol = self.mediaControl
        mediaControl.mediaProgressSlider
            .rx_controlEvent(.TouchDown)
            .subscribeNext { [weak mediacontrol] (_) -> Void in
                mediacontrol?.beginDragMediaSlider()
            }
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx_controlEvent(.TouchCancel)
            .subscribeNext { [weak mediaControl] (_) -> Void in
                mediaControl?.endDragMediaSlider()
            }
            .addDisposableTo(self.disposeBag)

        mediaControl.mediaProgressSlider
            .rx_controlEvent(.TouchUpOutside)
            .subscribeNext { [weak mediaControl] (_) -> Void in
                mediaControl?.endDragMediaSlider()
            }
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx_controlEvent(.TouchUpInside)
            .subscribeNext { [weak mediaControl, weak player] (_) -> Void in
                if let mediaControl = mediaControl, let player = player {
                    player.currentPlaybackTime = Double(mediaControl.mediaProgressSlider.value)
                    mediaControl.endDragMediaSlider()
                }
            }
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx_value
            .subscribeNext {  [weak mediaControl] (_) -> Void in
                mediaControl?.continueDragMediaSlider()
            }
            .addDisposableTo(self.disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.player.prepareToPlay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.shutdown()
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
}