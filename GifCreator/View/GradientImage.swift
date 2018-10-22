//
//  GradientImage.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/15/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit

class GradientImage: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    override func layoutSubviews() {
        
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 30.0
        let shadow = UIColor.black.withAlphaComponent(0.6).cgColor
        
//        let topImageGradient = CAGradientLayer()
//        topImageGradient.frame = CGRect(x: 0, y: 0, width: width, height: sHeight)
//        topImageGradient.colors = [shadow, UIColor.clear.cgColor]
//        self.layer.insertSublayer(topImageGradient, at: 0)
        
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        self.layer.insertSublayer(bottomImageGradient, at: 0)
        
        super.layoutSubviews()
    }

}
