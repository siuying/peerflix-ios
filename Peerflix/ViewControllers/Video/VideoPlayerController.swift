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
    
    var videoURL: URL?
    var services: ServiceFactory = DefaultServiceFactory.instance
    fileprivate let disposeBag = DisposeBag()
    fileprivate var torrent: TorrentService {
        return self.services.torrent
    }
    
    var playerOutputView: UIView!
    var player: VLCMediaPlayer!
    
    deinit {
        print("deinit VideoPlayerController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.player = VLCMediaPlayer()
        self.player.media = self.videoURL != nil ? VLCMedia(url: self.videoURL!) : VLCMedia()
        self.player.play()
        self.player.drawable = self.videoView
        self.player.delegate = self.mediaControl
        self.mediaControl.player = self.player
        
        let player = self.player
        let mediaControl: MediaControl! = self.mediaControl
        let gesture = UITapGestureRecognizer()
        gesture.rx.event
            .subscribe(onNext: {[weak mediaControl] (g) -> Void in
                if g.state == .ended {
                    mediaControl?.toggleVisibility()
                }
            })
            .addDisposableTo(self.disposeBag)
        self.mediaControl.isUserInteractionEnabled = true
        self.mediaControl.addGestureRecognizer(gesture)

        mediaControl.mediaProgressSlider
            .rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak mediaControl] (_) -> Void in
                mediaControl?.beginDragMediaSlider()
            })
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx.controlEvent(.touchCancel)
            .subscribe(onNext:  { [weak mediaControl] (_) -> Void in
                mediaControl?.endDragMediaSlider()
            })
            .addDisposableTo(self.disposeBag)

        mediaControl.mediaProgressSlider
            .rx.controlEvent(.touchUpOutside)
            .subscribe(onNext:  { [weak mediaControl] (_) -> Void in
                mediaControl?.endDragMediaSlider()
            })
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx.controlEvent(.touchUpInside)
            .subscribe(onNext:  { [weak mediaControl, weak player] (_) -> Void in
                if let mediaControl = mediaControl, let player = player {
                    player.time = VLCTime(int: Int32(mediaControl.mediaProgressSlider.value * 1000))
                    mediaControl.endDragMediaSlider()
                }
            })
            .addDisposableTo(self.disposeBag)
        
        mediaControl.mediaProgressSlider
            .rx.value
            .subscribe(onNext:  {  [weak mediaControl] (_) -> Void in
                mediaControl?.continueDragMediaSlider()
            })
            .addDisposableTo(self.disposeBag)
        
        mediaControl.doneButton
            .rx.tap
            .subscribe(onNext:  { [weak self] _ in
                if let vc = self {
                    _ = vc.navigationController?.popViewController(animated: true)
                }
            })
            .addDisposableTo(self.disposeBag)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player.pause()
        self.player.stop()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}
