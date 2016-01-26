//
//  SpotlightView.swift
//  Gecco
//
//  Created by yukiasai on 2016/01/16.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

public class SpotlightView: UIView {
    public static let defaultAnimateDuration: NSTimeInterval = 0.25
    
    var spotlight = Spotlight(shape: .Oval(center: CGPointZero, diameter: 100))
    
    var label: UILabel! = UILabel()
    
    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = kCAFillRuleEvenOdd
        layer.fillColor = UIColor.blackColor().CGColor
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.mask = maskLayer
        
        self.label.textColor = UIColor.whiteColor()
        self.label.font = UIFont(name: "Futura-Medium", size: 16)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        maskLayer.frame = frame
    }
    
    public func appear(spotlight: Spotlight? = nil, duration: NSTimeInterval = SpotlightView.defaultAnimateDuration) {
        let light: Spotlight = spotlight ?? self.spotlight
        
        if let text = self.spotlight.text {
            self.label.text = text
            self.label.sizeToFit()
            
            let center = light.shape.center
            let distanceToEdge = light.shape.size.height / CGFloat(2)
            let labelWidth = self.label.frame.width
            let horizontalGap = CGFloat(12)
            self.label.frame = CGRectMake(center.x - labelWidth / 2, center.y + distanceToEdge + horizontalGap, labelWidth, self.label.frame.height)
            
            self.addSubview(self.label)
        }
        
        maskLayer.addAnimation(appearAnimation(duration, spotlight: light), forKey: nil)
    }
    
    public func disappear(duration: NSTimeInterval = SpotlightView.defaultAnimateDuration) {
        maskLayer.addAnimation(disappearAnimation(duration), forKey: nil)
    }
   
    public func move(toSpotlight: Spotlight, duration: NSTimeInterval = SpotlightView.defaultAnimateDuration, moveType: SpotlightMoveType = .Direct) {
        switch moveType {
        case .Direct:
            moveDirect(toSpotlight, duration: duration)
        case .Disappear:
            moveDisappear(toSpotlight, duration: duration)
        }
    }
}

extension SpotlightView {
    private func moveDirect(toSpotlight: Spotlight, duration: NSTimeInterval = SpotlightView.defaultAnimateDuration) {
        maskLayer.addAnimation(moveAnimation(duration, toSpotlight: toSpotlight), forKey: nil)
        spotlight = toSpotlight
    }
    
    private func moveDisappear(toSpotlight: Spotlight, duration: NSTimeInterval = SpotlightView.defaultAnimateDuration) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.appear(toSpotlight, duration: duration)
            self.spotlight = toSpotlight
        }
        disappear(duration)
        CATransaction.commit()
    }
    
    private func maskPath(path: UIBezierPath) -> UIBezierPath {
        return [path].reduce(UIBezierPath(rect: frame)) {
            $0.appendPath($1)
            return $0
        }
    }
    
    private func appearAnimation(duration: NSTimeInterval, spotlight: Spotlight) -> CAAnimation {
        let beginPath = maskPath(spotlight.infinitesmalPath)
        let endPath = maskPath(spotlight.path)
        return pathAnimation(duration, beginPath:beginPath, endPath: endPath)
    }
    
    private func disappearAnimation(duration: NSTimeInterval) -> CAAnimation {
        let endPath = maskPath(spotlight.infinitesmalPath)
        return pathAnimation(duration, beginPath:nil, endPath: endPath)
    }
    
    private func moveAnimation(duration: NSTimeInterval, toSpotlight: Spotlight) -> CAAnimation {
        let endPath = maskPath(toSpotlight.path)
        return pathAnimation(duration, beginPath:nil, endPath: endPath)
    }
    
    private func pathAnimation(duration: NSTimeInterval, beginPath: UIBezierPath?, endPath: UIBezierPath) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.66, 0, 0.33, 1)
        if let path = beginPath {
            animation.fromValue = path.CGPath
        }
        animation.toValue = endPath.CGPath
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
}

public enum SpotlightMoveType {
    case Direct
    case Disappear
}