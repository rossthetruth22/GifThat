//
//  VideoThumbCell.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/15/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import Photos

class VideoThumbCell: UICollectionViewCell {
    
    @IBOutlet weak var image: GradientImage!
    @IBOutlet weak var videoTimeText: UILabel!
    var asset: PHAsset!
}
