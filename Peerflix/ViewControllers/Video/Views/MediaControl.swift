//
//  MediaControl.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import UIKit

private let LongFormatter : DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    formatter.unitsStyle = .positional
    return formatter
}()

private let Formatter : DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    formatter.unitsStyle = .positional
    return formatter
}()

class MediaControl: UIControl {
    weak var player: VLCMediaPlayer?

    @IBOutlet var overlayPanel: UIView!
    @IBOutlet var topPanel: UIView!
    @IBOutlet var bottomPanel: UIView!
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var doneButton: UIBarButtonItem!

    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var totalDurationLabel: UILabel!
    @IBOutlet var mediaProgressSlider: UISlider!
    
    var overlayHidden: Bool {
        return self.overlayPanel.isHidden
    }

    fileprivate var mediaSliderBeingDragged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.refresh()
    }

    func showNoFade() {
        self.overlayPanel.isHidden = false
        self.cancelDelayedHide()
        self.refresh()
    }
    
    func showAndFade() {
        self.showNoFade()
        self.perform(#selector(MediaControl.hide), with: nil, afterDelay: 5.0)
    }
    
    func hide() {
        self.overlayPanel.isHidden = true
        self.cancelDelayedHide()
    }
    
    func toggleVisibility() {
        if self.overlayPanel.isHidden {
            self.showAndFade()
        } else {
            self.hide()
        }
    }
    
    @objc func refresh() {
        guard let player = self.player else {
            self.currentTimeLabel.text = "--:--"
            self.totalDurationLabel.text = "--:--"
            self.mediaProgressSlider.value = 0
            return
        }
        
        let time = (player.time.value?.doubleValue ?? 0) / 1000
        let remain = (player.remainingTime?.value?.doubleValue ?? 0) / 1000
        let duration = time - remain

        // duration
        let intDuration = Int(duration + 0.5)
        if intDuration > 0 {
            self.mediaProgressSlider.maximumValue = Float(duration)
            if intDuration < 3600 {
                self.totalDurationLabel.text = Formatter.string(from: duration) ?? ""
            } else {
                self.totalDurationLabel.text = LongFormatter.string(from: duration) ?? ""
            }
        } else {
            self.mediaProgressSlider.maximumValue = 0
            self.totalDurationLabel.text = "--:--"
        }
        
        //position
        if !self.mediaSliderBeingDragged {
            let intPosition = Int(time + 0.5)
            if intPosition > 0 {
                if intPosition < 3600 {
                    self.currentTimeLabel.text = Formatter.string(from: time) ?? ""
                } else {
                    self.currentTimeLabel.text = LongFormatter.string(from: time) ?? ""
                }
                self.mediaProgressSlider.value = Float(time)
            } else {
                self.mediaProgressSlider.value = 0
                self.currentTimeLabel.text = "--:--"
            }            
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MediaControl.refresh), object: nil)
        if !self.overlayPanel.isHidden {
            self.perform(#selector(MediaControl.refresh), with: nil, afterDelay: 0.5)
        }
    }
    
    func beginDragMediaSlider() {
        self.mediaSliderBeingDragged = true
    }
    
    func endDragMediaSlider() {
        self.mediaSliderBeingDragged = false
    }
    
    func continueDragMediaSlider() {
        self.refresh()
    }
    
    fileprivate func cancelDelayedHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MediaControl.hide), object: nil)
    }
}

extension MediaControl: VLCMediaPlayerDelegate {
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        self.refresh()
    }
}
