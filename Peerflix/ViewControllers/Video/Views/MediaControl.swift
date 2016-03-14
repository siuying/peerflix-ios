//
//  MediaControl.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import UIKit

private let LongFormatter : NSDateComponentsFormatter = {
    let formatter = NSDateComponentsFormatter()
    formatter.allowedUnits = [.Hour, .Minute, .Second]
    formatter.zeroFormattingBehavior = [.Pad]
    formatter.unitsStyle = .Positional
    return formatter
}()

private let Formatter : NSDateComponentsFormatter = {
    let formatter = NSDateComponentsFormatter()
    formatter.allowedUnits = [.Minute, .Second]
    formatter.zeroFormattingBehavior = [.Pad]
    formatter.unitsStyle = .Positional
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
        return self.overlayPanel.hidden
    }

    private var mediaSliderBeingDragged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.refresh()
    }

    func showNoFade() {
        self.overlayPanel.hidden = false
        self.cancelDelayedHide()
        self.refresh()
    }
    
    func showAndFade() {
        self.showNoFade()
        self.performSelector("hide", withObject: nil, afterDelay: 5.0)
    }
    
    func hide() {
        self.overlayPanel.hidden = true
        self.cancelDelayedHide()
    }
    
    func toggleVisibility() {
        if self.overlayPanel.hidden {
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
                self.totalDurationLabel.text = Formatter.stringFromTimeInterval(duration) ?? ""
            } else {
                self.totalDurationLabel.text = LongFormatter.stringFromTimeInterval(duration) ?? ""
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
                    self.currentTimeLabel.text = Formatter.stringFromTimeInterval(time) ?? ""
                } else {
                    self.currentTimeLabel.text = LongFormatter.stringFromTimeInterval(time) ?? ""
                }
                self.mediaProgressSlider.value = Float(time)
            } else {
                self.mediaProgressSlider.value = 0
                self.currentTimeLabel.text = "--:--"
            }            
        }

        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "refresh", object: nil)
        if !self.overlayPanel.hidden {
            self.performSelector("refresh", withObject: nil, afterDelay: 0.5)
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
    
    private func cancelDelayedHide() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "hide", object: nil)
    }
}

extension MediaControl: VLCMediaPlayerDelegate {
    func mediaPlayerTimeChanged(aNotification: NSNotification!) {
        self.refresh()
    }
}
