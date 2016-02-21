//
//  MediaControl.swift
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import UIKit

class MediaControl: UIControl {
    weak var delegatePlayer: IJKMediaPlayback?
    var overlayPanel: UIView!
    var topPanel: UIToolbar!
    var bottomPanel: UIView!
    
    var playButton: UIButton!
    var pauseButton: UIButton!
    var doneButton: UIBarButtonItem!

    var currentTimeLabel: UILabel!
    var totalDurationLabel: UILabel!
    var mediaProgressSlider: UISlider!
    
    private var mediaSliderBeingDragged = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.overlayPanel = UIView(frame: self.bounds)
        self.overlayPanel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.overlayPanel)
        self.overlayPanel.leftAnchor.constraintEqualToAnchor(self.overlayPanel.leftAnchor).active = true
        self.overlayPanel.rightAnchor.constraintEqualToAnchor(self.overlayPanel.rightAnchor).active = true
        self.overlayPanel.topAnchor.constraintEqualToAnchor(self.overlayPanel.topAnchor).active = true
        self.overlayPanel.bottomAnchor.constraintEqualToAnchor(self.overlayPanel.bottomAnchor).active = true
        
        self.topPanel = self.createTopPanel()
        self.bottomPanel = self.createBottomPanel()
    }
    
    func createTopPanel() -> UIToolbar {
        let topPanel = UIToolbar()
        topPanel.translatesAutoresizingMaskIntoConstraints = false

        self.doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        topPanel.items = [self.doneButton, flex]
        
        self.overlayPanel.addSubview(self.topPanel)
        self.topPanel.heightAnchor.constraintEqualToConstant(44).active = true
        self.topPanel.widthAnchor.constraintEqualToAnchor(self.overlayPanel.widthAnchor).active = true
        self.topPanel.topAnchor.constraintEqualToAnchor(self.overlayPanel.topAnchor).active = true
        self.topPanel.leftAnchor.constraintEqualToAnchor(self.overlayPanel.leftAnchor).active = true
        
        return topPanel
    }
    
    func createBottomPanel() -> UIView {
        let bottomPanel = UIView()
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        self.overlayPanel.addSubview(bottomPanel)
        bottomPanel.heightAnchor.constraintEqualToConstant(80).active = true
        bottomPanel.widthAnchor.constraintEqualToAnchor(self.overlayPanel.widthAnchor).active = true
        bottomPanel.bottomAnchor.constraintEqualToAnchor(self.overlayPanel.bottomAnchor).active = true
        bottomPanel.leftAnchor.constraintEqualToAnchor(self.overlayPanel.leftAnchor).active = true

        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.addSubview(backgroundView)
        bottomPanel.heightAnchor.constraintEqualToAnchor(backgroundView.heightAnchor).active = true
        bottomPanel.widthAnchor.constraintEqualToAnchor(backgroundView.widthAnchor).active = true
        bottomPanel.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor).active = true
        bottomPanel.leftAnchor.constraintEqualToAnchor(backgroundView.leftAnchor).active = true

        self.playButton = UIButton(type: .System)
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.setTitle("Play", forState: .Normal)

        self.pauseButton = UIButton(type: .System)
        self.pauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.pauseButton.setTitle("Pause", forState: .Normal)
        
        let stack = UIStackView()
        stack.axis = .Horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .Fill
        stack.alignment = .Center
        bottomPanel.addSubview(stack)

        self.currentTimeLabel = UILabel()
        self.currentTimeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        self.currentTimeLabel.textColor = UIColor.whiteColor()
        stack.addArrangedSubview(self.currentTimeLabel)

        self.mediaProgressSlider = UISlider()
        self.mediaProgressSlider.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(self.mediaProgressSlider)
        
        self.totalDurationLabel = UILabel()
        self.totalDurationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        self.totalDurationLabel.textColor = UIColor.whiteColor()
        stack.addArrangedSubview(self.totalDurationLabel)
        
        return bottomPanel
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func refresh() {
        
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
