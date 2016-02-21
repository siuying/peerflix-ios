import Foundation
import UIKit
import XCPlayground

class MediaControl: UIControl {
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
        self.translatesAutoresizingMaskIntoConstraints = false

        self.overlayPanel = UIView(frame: self.bounds)
        self.overlayPanel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(self.overlayPanel)
        self.overlayPanel.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        self.overlayPanel.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        self.overlayPanel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        self.overlayPanel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true

        let (topPanel, doneButton) = self.createTopPanel(self.overlayPanel)
        self.topPanel = topPanel
        self.doneButton = doneButton
        
        let (bottomPanel, currentTimeLabel, mediaProgressSlider, totalDurationLabel) = self.createBottomPanel(self.overlayPanel)
        self.bottomPanel = bottomPanel
        self.currentTimeLabel = currentTimeLabel
        self.mediaProgressSlider = mediaProgressSlider
        self.totalDurationLabel = totalDurationLabel
    }
    
    func createTopPanel(overlay: UIView) -> (UIToolbar, UIBarButtonItem) {
        let topPanel = UIToolbar()
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        topPanel.items = [doneButton, flex]
        
        overlay.addSubview(topPanel)
        topPanel.heightAnchor.constraintEqualToConstant(44).active = true
        overlay.widthAnchor.constraintEqualToAnchor(topPanel.widthAnchor).active = true
        overlay.topAnchor.constraintEqualToAnchor(topPanel.topAnchor).active = true
        overlay.centerXAnchor.constraintEqualToAnchor(topPanel.centerXAnchor).active = true
        
        return (topPanel, doneButton)
    }
    
    func createBottomPanel(overlay: UIView) -> (UIView, UILabel, UISlider, UILabel) {
        let bottomPanel = UIStackView()
        bottomPanel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(bottomPanel)

//        bottomPanel.heightAnchor.constraintEqualToConstant(60).active = true
        overlay.widthAnchor.constraintEqualToAnchor(bottomPanel.widthAnchor).active = true
        overlay.bottomAnchor.constraintEqualToAnchor(bottomPanel.bottomAnchor).active = true
        overlay.centerXAnchor.constraintEqualToAnchor(bottomPanel.centerXAnchor).active = true

        let stack = UIStackView(frame: bottomPanel.bounds)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .Horizontal
        stack.spacing = 10
        stack.alignment = .Fill
        stack.distribution = .Fill
        stack.layoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12)
        bottomPanel.addSubview(stack)

        bottomPanel.heightAnchor.constraintEqualToAnchor(stack.heightAnchor).active = true
        bottomPanel.widthAnchor.constraintEqualToAnchor(stack.widthAnchor).active = true
        bottomPanel.centerYAnchor.constraintEqualToAnchor(stack.centerYAnchor).active = true
        bottomPanel.centerXAnchor.constraintEqualToAnchor(stack.centerXAnchor).active = true

        let currentTimeLabel = UILabel()
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        currentTimeLabel.text = "--:--:--"
        currentTimeLabel.textColor = UIColor.whiteColor()
        currentTimeLabel.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
        stack.addArrangedSubview(currentTimeLabel)
        
        let mediaProgressSlider = UISlider()
        mediaProgressSlider.translatesAutoresizingMaskIntoConstraints = false
        mediaProgressSlider.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
        mediaProgressSlider.setContentHuggingPriority(750, forAxis: .Horizontal)
        stack.addArrangedSubview(mediaProgressSlider)
        
        let totalDurationLabel = UILabel()
        totalDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        totalDurationLabel.text = "--:--:--"
        totalDurationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        totalDurationLabel.textColor = UIColor.whiteColor()
        totalDurationLabel.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
        stack.addArrangedSubview(totalDurationLabel)
        
        return (bottomPanel, currentTimeLabel, mediaProgressSlider, totalDurationLabel)
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

let view = UIView(frame: CGRectZero)
view.translatesAutoresizingMaskIntoConstraints = false
view.backgroundColor = UIColor.orangeColor()
view.widthAnchor.constraintEqualToConstant(1334).active = true
view.heightAnchor.constraintEqualToConstant(750).active = true

let control = MediaControl(frame: CGRectZero)
view.addSubview(control)

control.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
control.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
control.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
control.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true

XCPlaygroundPage.currentPage.liveView = view
view.setNeedsUpdateConstraints()
view.setNeedsLayout()
