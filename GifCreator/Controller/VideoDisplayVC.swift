//
//  VideoDisplayVC.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/15/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import Photos

class VideoDisplayVC: UIViewController {
    
    //var videoDictionaries: [[String:AnyObject]]?
    var videoThumbs: [VideoThumb]?
    //var pictureService: PhotoService!
    //var videoURL: String!
    var passedURL: URL!
    let cachingManager = PHCachingImageManager()
    var assetCollection: PHAssetCollection?
    var fetchResult: PHFetchResult<PHAsset>!
    var size: CGSize!

    let trimSegue = "trimSegue"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        //pictureService = PhotoService()
        
        size = CGSize(width: dimension, height: dimension)
        fetchVideoAssets()
        //videoThumbs = get
        //videoDictionaries = getVideos(size: CGSize(width: dimension, height: dimension))
        //print("Thumb count is \(videoDictionaries?.count)")


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            if let controller = segue.destination as? VideoEditingVC{
                controller.videoURL = passedURL
            }
        }
        
        if segue.identifier == "trimSegue"{
            if let controller = segue.destination as? VideoCutter{
    
                let indexPath = collectionView.indexPathsForSelectedItems?.first
                if let cell = collectionView.cellForItem(at: indexPath!) as? VideoThumbCell{
                    let asset = cell.asset
                        controller.asset = asset
                }
                
                controller.url = self.passedURL
            }
        }
    }
    
    
    func fetchVideoAssets(){
        
        
        
        assetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil).firstObject
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(in: assetCollection!, options: options)
        
        let assets = fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count))
        
        cachingManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFit, options: nil)
        
        self.videoThumbs = getThumbImage(assets: assets)
        
        //DispatchQueue.main.async {
        //    self.collectionView.reloadData()
        //}
        
    }
    
    func getThumbImage(assets: [PHAsset]) -> [VideoThumb]? {
        //var images = [UIImage]()
        
        guard assets.count > 0 else{return nil}
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        
        var videoThumbs = [VideoThumb]()
        
        for asset in assets{
            cachingManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, dictionary) in
                if let image = image{
                    
                    
                    let duration = asset.duration
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .positional
                    formatter.allowedUnits = [.minute, .second]
                    formatter.zeroFormattingBehavior = [.pad]
                    let formattedDuration = formatter.string(from: duration)
                    
                    let videoThumb = VideoThumb(asset: asset, image: image, time: formattedDuration!)
                    //let assetDictionary = ["Asset": asset, "Image": image, "Time": formattedDuration!] as [String : AnyObject]
                    
                    videoThumbs.append(videoThumb)
                    //assetDictionaries.append(assetDictionary)
                }
            }
        }
        return videoThumbs
    }
    
    func getVideoPath(_ asset: PHAsset, completionHandlerForURL: @escaping (_ URL: URL?) -> Void){
        
        cachingManager.requestAVAsset(forVideo: asset, options: nil) { (video, audioMix, dictionary) in
            if let video = video as? AVURLAsset{
                completionHandlerForURL(video.url)
            }else{
                completionHandlerForURL(nil)
            }
        }
    }
}

extension VideoDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoThumbs?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoThumbCell", for: indexPath) as? VideoThumbCell{
            guard let thumbs = videoThumbs else {return UICollectionViewCell()}
            let thumb = thumbs[indexPath.row]
            let asset = thumb.asset
            let image = thumb.image
            let time = thumb.time
//            guard let asset = dictionary["Asset"] as? PHAsset else {return UICollectionViewCell()}
//            guard let image = dictionary["Image"] as? UIImage else {return UICollectionViewCell()}
//            guard let time = dictionary["Time"] as? String else {return UICollectionViewCell()}
            
            cell.image.image = image
            cell.videoTimeText.text = time
            cell.asset = asset
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! VideoThumbCell
        let asset = cell.asset
        
        getVideoPath(asset!) { (url) in
            if let url = url{
                self.passedURL = url
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.trimSegue, sender: self)
                }
            }
        }
    }
}

extension VideoDisplayVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            if let albumChanges = changeInstance.changeDetails(for: self.assetCollection!){
                self.assetCollection = albumChanges.objectAfterChanges!
            }
            
            if let changes = changeInstance.changeDetails(for: self.fetchResult!){
                
                
                self.fetchResult = changes.fetchResultAfterChanges
                print("new fetch result count")
                print(self.fetchResult?.count)
                
                
                if changes.hasIncrementalChanges {
                    self.collectionView.performBatchUpdates({
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            
                            let _ = removed.enumerated().map({ (index, indexSet) in
                                //self.images?.remove(at: indexSet - index)
                                self.videoThumbs?.remove(at: indexSet - index)
                                return
                            })
                            
                            self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                            
                        }
                        
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            let thumbs = self.getThumbImage(assets: changes.insertedObjects)
                            
                            let _ = inserted.enumerated().map({ (index, indexSet) in
                                self.videoThumbs?.insert(thumbs![index], at: indexSet)
                                return
                            })
                            self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                        }
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            
                        }
                        
                        
                    }, completion: {(truth) in
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            //let _ = changed.map{print("changed indexes: \($0)")}
                            //let _ = changed.map{changeInstance.changeDetails(for: changes.changedObjects[$0])}
                            //self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                            
                        }
                        
                        changes.enumerateMoves { fromIndex, toIndex in
                            print("from: \(fromIndex), to: \(toIndex)")
                            self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                         to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                    
                }else{
                    
                    print("else")
                    self.fetchVideoAssets()
                }
            }
        }
    }
}
