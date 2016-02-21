import Foundation
import UIKit
import XCPlayground

func createBottomPanel() -> (bottomPanel: UIView,
    currentTimeLabel: UILabel, mediaProgressSlider: UISlider, totalDurationLabel: UILabel) {
    let bottomPanel = UIView()
    bottomPanel.translatesAutoresizingMaskIntoConstraints = false

    let backgroundView = UIView()
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
    bottomPanel.addSubview(backgroundView)

    bottomPanel.heightAnchor.constraintEqualToAnchor(backgroundView.heightAnchor).active = true
    bottomPanel.widthAnchor.constraintEqualToAnchor(backgroundView.widthAnchor).active = true
    bottomPanel.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor).active = true
    bottomPanel.leftAnchor.constraintEqualToAnchor(backgroundView.leftAnchor).active = true
    
    let stack = UIStackView()
    stack.layoutMarginsRelativeArrangement = true
    stack.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12)
    stack.axis = .Horizontal
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .Fill
    stack.alignment = .Center
    stack.spacing = 10
    bottomPanel.addSubview(stack)

    stack.heightAnchor.constraintEqualToConstant(60).active = true
    stack.widthAnchor.constraintEqualToAnchor(bottomPanel.widthAnchor).active = true
    stack.bottomAnchor.constraintEqualToAnchor(bottomPanel.bottomAnchor).active = true
    stack.leftAnchor.constraintEqualToAnchor(bottomPanel.leftAnchor).active = true

    let currentTimeLabel = UILabel()
    currentTimeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCallout)
    currentTimeLabel.textColor = UIColor.whiteColor()
    currentTimeLabel.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    currentTimeLabel.text = "00:00:00"
    stack.addArrangedSubview(currentTimeLabel)

    let mediaProgressSlider = UISlider()
    mediaProgressSlider.translatesAutoresizingMaskIntoConstraints = false
    mediaProgressSlider.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
    mediaProgressSlider.setContentHuggingPriority(750, forAxis: .Horizontal)
    stack.addArrangedSubview(mediaProgressSlider)

    let totalDurationLabel = UILabel()
    totalDurationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCallout)
    totalDurationLabel.textColor = UIColor.whiteColor()
    totalDurationLabel.setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    totalDurationLabel.text = "1:20:30"
    stack.addArrangedSubview(totalDurationLabel)

    return (
        bottomPanel: bottomPanel,
        currentTimeLabel: currentTimeLabel, mediaProgressSlider: mediaProgressSlider, totalDurationLabel: totalDurationLabel
    )
}

let view = UIView()
let (bottomPanel, _, _, _) = createBottomPanel()

view.translatesAutoresizingMaskIntoConstraints = false
view.backgroundColor = UIColor.yellowColor()
view.widthAnchor.constraintEqualToConstant(640).active = true
view.heightAnchor.constraintEqualToConstant(480).active = true
view.addSubview(bottomPanel)

bottomPanel.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
bottomPanel.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
bottomPanel.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
bottomPanel.heightAnchor.constraintEqualToConstant(80).active = true

XCPlaygroundPage.currentPage.liveView = view
