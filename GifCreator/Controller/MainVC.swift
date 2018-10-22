//
//  ViewController.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/4/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import MobileCoreServices
import FLAnimatedImage
import Photos


class MainVC: UIViewController, UIVideoEditorControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var images: [FLAnimatedImage]?
    var thumbs: [UIImage]?
    //var pictures: PhotoService?
    let cachingManager = PHCachingImageManager()
    var assetCollection: PHAssetCollection?
    var fetchResult: PHFetchResult<PHAsset>!
    var size: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        size = CGSize(width: dimension, height: dimension)
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PHPhotoLibrary.requestAuthorization { (authStatus) in
            if authStatus == .authorized{
                PHPhotoLibrary.shared().register(self)
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                
                self.fetchPhotoAssets()
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                
            }else{
                DispatchQueue.main.async {
                    self.retrievePhotoLibraryAuthority()
                }
                
                print("not authorized")
            }

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //pictures = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            if let controller = segue.destination as? GifDetailVC{
                if let indexPath = collectionView.indexPathsForSelectedItems?.first{
                    //let cell = collectionView.cellForItem(at: indexPath) as! GifCell
                    controller.detailGif = images![indexPath.row]
                }
            }
        }
        
//        else if segue.identifier == "videoThumbSegue"{
//            if let controller = segue.destination as? VideoDisplayVC{
//
//            }
//        }
    }
    
    
    func fetchPhotoAssets(){
        
        assetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: nil).firstObject
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(in: assetCollection!, options: options)
        
        let assets = fetchResult.objects(at: IndexSet(integersIn: 0..<fetchResult.count))
        
        cachingManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFit, options: nil)
        
        self.images = getImageDataFromCachingManager(assets: assets)
        self.thumbs = getThumbImage(assets: assets)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func getImageDataFromCachingManager(assets: [PHAsset]) -> [FLAnimatedImage]?{

        var images = [FLAnimatedImage]()
        
        
        guard assets.count > 0 else{
            return nil
        }

        let options = PHImageRequestOptions()
        options.isSynchronous = true
        for asset in assets{
            cachingManager.requestImageData(for: asset, options: options) { (imageData, _, _, _) in
                if let imageData = imageData{
                    images.append(FLAnimatedImage(animatedGIFData: imageData))
                }
            }
        }

        return images
        
    }
    
    func getThumbImage(assets: [PHAsset]) -> [UIImage]? {
        //var images = [UIImage]()
        
        guard assets.count > 0 else{return nil}
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        
        var thumbs = [UIImage]()
        for asset in assets{
            cachingManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
                if let image = image{
                    thumbs.append(image)
                    
                }
            }
        }
        return thumbs
    }
    
    func retrievePhotoLibraryAuthority(){
        
        let alertController = UIAlertController(title: "Photo Library Authority", message: "Authorization to Photo Library is requird for this app!", preferredStyle: .alert)
        
        let settings = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settings)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cellPressed(_ sender: UITapGestureRecognizer) {
        
        let touch = sender.location(in: collectionView)
            
        if let indexPath = collectionView.indexPathForItem(at: touch){
            if let cell = collectionView.cellForItem(at: indexPath) as? GifCell{
                cell.gifImage.image = nil
                
                cell.gifImage.loopCompletionBlock = { (uint: UInt) -> Void in
                    cell.gifImage.stopAnimating()
                    cell.gifImage.image = self.thumbs?[indexPath.row]
                }
                cell.gifImage.animatedImage = images![indexPath.row]
                
            }
        }
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifCell", for: indexPath) as? GifCell{

            guard let realImages = thumbs else {return UICollectionViewCell()}
            //let asset = fetchResult.object(at: indexPath.row)
            //cell.populateCell(with: asset)
            cell.gifImage.image = realImages[indexPath.row]
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //print("did end")
    }
    
}

extension MainVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
       
        DispatchQueue.main.async {
            if let albumChanges = changeInstance.changeDetails(for: self.assetCollection!){
                self.assetCollection = albumChanges.objectAfterChanges!
            }
            
            if let changes = changeInstance.changeDetails(for: self.fetchResult!){
                
                
                self.fetchResult = changes.fetchResultAfterChanges
                print("new fetch result count")
                print(self.fetchResult?.count)
                
                //This works
                
//                if changes.hasIncrementalChanges{
//                    if let removed = changes.removedIndexes, removed.count > 0 {
//
//                        let _ = removed.enumerated().map({ (index, indexSet) in
//                            self.images?.remove(at: indexSet - index)
//                            self.thumbs?.remove(at: indexSet - index)
//                            return
//                        })
//                    }
//
//                    if let inserted = changes.insertedIndexes, inserted.count > 0{
//
//                        let gifs = self.getImageDataFromCachingManager(assets: changes.insertedObjects)
//                        let thumbs = self.getThumbImage(assets: changes.insertedObjects)
//
//                        let _ = inserted.enumerated().map({ (index, indexSet) in
//                            self.images?.insert(gifs![index], at: indexSet)
//                            self.thumbs?.insert(thumbs![index], at: indexSet)
//                            return
//                        })
//                    }
//
//                    if let changed = changes.changedIndexes, changed.count > 0{
//                        print("we got changes")
//                    }
//
//                    self.collectionView.reloadData()
//
//                }
                
                if changes.hasIncrementalChanges {
                    self.collectionView.performBatchUpdates({
                        if let removed = changes.removedIndexes, removed.count > 0 {

                            let _ = removed.enumerated().map({ (index, indexSet) in
                                self.images?.remove(at: indexSet - index)
                                self.thumbs?.remove(at: indexSet - index)
                                return
                            })
                            
                            self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })

                        }

                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            let gifs = self.getImageDataFromCachingManager(assets: changes.insertedObjects)
                            let thumbs = self.getThumbImage(assets: changes.insertedObjects)
                            
                            let _ = inserted.map{print("inserted indexes: \($0)")}

                            let _ = inserted.enumerated().map({ (index, indexSet) in
                                self.images?.insert(gifs![index], at: indexSet)
                                self.thumbs?.insert(thumbs![index], at: indexSet)
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
                    self.fetchPhotoAssets()
                }
            }
        }
    }
}

