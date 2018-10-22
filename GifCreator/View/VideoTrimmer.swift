//
//  VideoTrimmer.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/30/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit

//@IBDesignable

class VideoTrimmer: UIView {
    
    let kCONTENT_XIB_NAME = "VideoTrimmer"

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var leftBar: UIView!
    @IBOutlet weak var rightBar: UIView!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellImages:[UIImage]?
    
    var cellWidth: CGFloat {
        return collectionView.bounds.width / 7
    }
    
    var cellHeight: CGFloat {
        return collectionView.bounds.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "VideoFrameCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "VideoFrameCell")
    }
    
    func commonInit(){
        //Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView = loadViewFromNib()
        //contentView.fixInView(self)
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        let leftRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleLeftBar(_:)))
        leftBar.addGestureRecognizer(leftRecognizer)
        let rightRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleRightBar(_:)))
        rightBar.addGestureRecognizer(rightRecognizer)
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
        
    }
    
    func getFrames(){
        let pictureService = PhotoService()
        //pictureService.cachingManager.
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kCONTENT_XIB_NAME, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc func handleLeftBar(_ recognizer: UIPanGestureRecognizer){
        let originX = recognizer.view?.frame.origin.x
        let topBarOriginX = topBar.frame.origin.x
        let topBarOriginY = topBar.frame.origin.y
        let topBarWidth = topBar.frame.width
        let topBarHeight = topBar.frame.height
        
        let bottomBarOriginX = bottomBar.frame.origin.x
        let bottomBarOriginY = bottomBar.frame.origin.y
        let bottomBarWidth = bottomBar.frame.width
        let bottomBarHeight = bottomBar.frame.height
        
        switch recognizer.state{
        case .began:
            print("began")
        case .changed:
            if let rview = recognizer.view{
                rview.center.x = rview.center.x + recognizer.translation(in: rview).x
                topBar.frame = CGRect(x: topBarOriginX + recognizer.translation(in: rview).x, y: topBarOriginY, width: topBarWidth - recognizer.translation(in: rview).x, height: topBarHeight)
                
                bottomBar.frame = CGRect(x: bottomBarOriginX + recognizer.translation(in: rview).x, y: bottomBarOriginY, width: bottomBarWidth - recognizer.translation(in: rview).x, height: bottomBarHeight)
                //topBar.bounds.size.width = topBar.bounds.size.width - recognizer.translation(in: rview).x
                //bottomBar.bounds.size.width = bottomBar.bounds.size.width - recognizer.translation(in: rview).x
                recognizer.setTranslation(CGPoint.zero, in: rview)
            }
            //print("changed")
        case .ended:
            print("ended")
        default:
            break
            
        }
            
        
        
    }
    
    @objc func handleRightBar(_ recognizer: UIPanGestureRecognizer){
        
        let originX = recognizer.view?.frame.origin.x
        let topBarOriginX = topBar.frame.origin.x
        let topBarOriginY = topBar.frame.origin.y
        let topBarWidth = topBar.frame.width
        let topBarHeight = topBar.frame.height
        
        let bottomBarOriginX = bottomBar.frame.origin.x
        let bottomBarOriginY = bottomBar.frame.origin.y
        let bottomBarWidth = bottomBar.frame.width
        let bottomBarHeight = bottomBar.frame.height
        
        switch recognizer.state{
        case .began:
            print("began")
        case .changed:
            if let rview = recognizer.view{
                rview.center.x = rview.center.x + recognizer.translation(in: rview).x
                topBar.frame = CGRect(x: topBarOriginX, y: topBarOriginY, width: topBarWidth + recognizer.translation(in: rview).x, height: topBarHeight)
                
                bottomBar.frame = CGRect(x: bottomBarOriginX, y: bottomBarOriginY, width: bottomBarWidth + recognizer.translation(in: rview).x, height: bottomBarHeight)
                //topBar.bounds.size.width = topBar.bounds.size.width - recognizer.translation(in: rview).x
                //bottomBar.bounds.size.width = bottomBar.bounds.size.width - recognizer.translation(in: rview).x
                recognizer.setTranslation(CGPoint.zero, in: rview)
            }
            //print("changed")
        case .ended:
            print("ended")
        default:
            break
            
        }
        
    }

}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension VideoTrimmer: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFrameCell", for: indexPath) as? VideoFrameCell{
            guard let picture = cellImages?[indexPath.row] else {return UICollectionViewCell()}
            cell.cellImage.image = picture
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}
