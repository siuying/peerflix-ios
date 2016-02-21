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
    var services: ServiceFactory = DefaultServiceFactory.instance

    private let disposeBag = DisposeBag()
    private var torrent: TorrentService {
        return self.services.torrent
    }

    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var downloadedLabel : UILabel!
    @IBOutlet var downloadSpeedLabel : UILabel!
    @IBOutlet var playButton : UIButton!

    deinit {
        print("deinit TorrentViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let play = self.playButton.rx_tap.asObservable()

        self.viewModel = TorrentViewModel(play: play, torrent: self.torrent)
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

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       guard let segueId = segue.identifier else {
           return
       }
    
       if segueId == Segue.PlayVideo.rawValue {
           let vc = segue.destinationViewController as! VideoPlayerController
           vc.videoURL = self.viewModel.videoURL.value
       }
   }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = nil
    }
}

extension TorrentViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        // when pop to SearchViewController, deselect any torrent
        if viewController is SearchViewController {

        }
    }
}