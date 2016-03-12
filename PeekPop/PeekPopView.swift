//
//  PeekPopView.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 09/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class PeekPopView: UIView {
    
    //MARK: Screenshots
    
    var viewControllerScreenshot: UIImage? = nil {
        didSet {
            blurredScreenshots.removeAll()
        }
    }
    var targetViewControllerScreenshot: UIImage? = nil
    var sourceViewScreenshot: UIImage?
    var blurredScreenshots = [UIImage]()
    
    var sourceViewRect = CGRect.zero
    
    //MARK: Subviews

    // Blurry image views, used for interpolation
    var blurredBaseImageView = UIImageView()
    var blurredImageViewFirst = UIImageView()
    var blurredImageViewSecond = UIImageView()
    
    // Overlay view
    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.85, alpha: 0.5)
        return view
    }()
    
    // Source image view
    var sourceImageView = UIImageView()
    
    // Target preview view
    var targetPreviewView = PeekPopTargetPreviewView()

    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        self.addSubview(blurredBaseImageView)
        self.addSubview(blurredImageViewFirst)
        self.addSubview(blurredImageViewSecond)
        self.addSubview(overlayView)
        self.addSubview(sourceImageView)
        self.addSubview(targetPreviewView)
    }
    
    func didAppear() {
        blurredBaseImageView.frame = self.bounds
        blurredImageViewFirst.frame = self.bounds
        blurredImageViewSecond.frame = self.bounds
        overlayView.frame = self.bounds
        targetPreviewView.frame.size = sourceViewRect.size
        targetPreviewView.imageViewFrame = self.bounds
        sourceImageView.frame = sourceViewRect
        sourceImageView.image = sourceViewScreenshot
    }
    
    func animateProgressiveBlur(progress: CGFloat) {
        let blur = progress*CGFloat(blurredScreenshots.count - 1)
        let blurIndex = Int(blur)
        let blurRemainder = blur - CGFloat(blurIndex)
        blurredBaseImageView.image = blurredScreenshots.last
        blurredImageViewFirst.image = blurredScreenshots[blurIndex]
        blurredImageViewSecond.image = blurredScreenshots[blurIndex + 1]
        blurredImageViewSecond.alpha = CGFloat(blurRemainder)
    }
    
    func animateProgress(progress: CGFloat) {
        
        sourceImageView.hidden = progress > 0.33
        targetPreviewView.hidden = progress < 0.33

        // Source rect expand stage
        if progress < 0.3 {
            let adjustedProgress = min(progress*3,1.0)
            animateProgressiveBlur(adjustedProgress)
            let adjustedScale: CGFloat = 1.0 - CGFloat(adjustedProgress)*0.015
            let adjustedSourceImageScale: CGFloat = 1.0 + CGFloat(adjustedProgress)*0.015
            blurredImageViewFirst.transform = CGAffineTransformMakeScale(adjustedScale, adjustedScale)
            blurredImageViewSecond.transform = CGAffineTransformMakeScale(adjustedScale, adjustedScale)
            overlayView.alpha = CGFloat(adjustedProgress)
            sourceImageView.transform = CGAffineTransformMakeScale(adjustedSourceImageScale, adjustedSourceImageScale)
        }
        // Target preview reveal stage
        else if progress < 0.45 {
            let targetAdjustedScale: CGFloat = min(CGFloat((progress - 0.34)/(0.44-0.34)), CGFloat(1.0))
            let sourceViewCenter = CGPointMake(sourceViewRect.origin.x + sourceViewRect.size.width/2, sourceViewRect.origin.y + sourceViewRect.size.height/2)
            let originXDelta = self.bounds.size.width/2 - sourceViewCenter.x
            let originYDelta = self.bounds.size.height/2 - sourceViewCenter.y
            let widthDelta = self.bounds.size.width - 28 - sourceViewRect.size.width
            let heightDelta = self.bounds.size.height - 140 - sourceViewRect.size.height
            targetPreviewView.imageView.image = targetViewControllerScreenshot
            targetPreviewView.frame.size = CGSizeMake(sourceViewRect.size.width + widthDelta*targetAdjustedScale, sourceViewRect.size.height + heightDelta*targetAdjustedScale)
            targetPreviewView.center = CGPointMake(sourceViewCenter.x + originXDelta*targetAdjustedScale, sourceViewCenter.y + originYDelta*targetAdjustedScale)
        }
        // Target preview expand stage
        else if progress < 0.96 {
            let targetAdjustedScale = min(CGFloat(1 + (progress-0.66)/6),1.1)
            targetPreviewView.transform = CGAffineTransformMakeScale(targetAdjustedScale, targetAdjustedScale)
        }
        // Commit target view controller
        else {
            targetPreviewView.frame = self.bounds
            targetPreviewView.imageContainer.layer.cornerRadius = 0
        }

    }
        
}

class PeekPopTargetPreviewView: UIView {
    
    var imageContainer = UIImageView()
    var imageView = UIImageView()
    var imageViewFrame = CGRect.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageContainer.frame = self.bounds
        imageView.frame = imageViewFrame
        imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setup() {
        self.addSubview(imageContainer)
        imageContainer.layer.cornerRadius = 15
        imageContainer.clipsToBounds = true
        imageContainer.addSubview(imageView)
    }
}


