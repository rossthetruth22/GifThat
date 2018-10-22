//
//  VideoEditingVC.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/7/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import FLAnimatedImage
import YGCTrimVideoView
import GIFGenerator
import Photos
import AVFoundation
import Regift

class VideoEditingVC: UIViewController {
    
    

    @IBOutlet weak var gifView: FLAnimatedImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var importAsset: TrimmedVideo!
    var videoURL: URL!
    private var tempGifURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        tempGifURL = createTemporaryURL(pathComponent: "temp_gif.gif")
        deleteTemporaryFile(tempGifURL)
        
        
        createTemporaryVideoFileFromAsset(asset: importAsset) { (url) in
            guard let videoURL = url else {return}
            self.videoURL = videoURL
            
            let asset = AVURLAsset(url: self.videoURL)
            let duration = CMTimeGetSeconds(asset.duration)
            let fps = 24
            let frameCount = Int(duration) * fps
            let delayTime = Float(0.042)
            let loopCount = 0
            print(duration)
            
            Regift.createGIFFromSource(self.videoURL, destinationFileURL: self.tempGifURL, frameCount: frameCount, delayTime: delayTime, loopCount: 0, size: nil) { (url) in
                
                if let url = url{
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.gifView.animatedImage = FLAnimatedImage(animatedGIFData: data)
                        }
                    } catch {
                        print("unable to fetch gif")
                    }
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
        }
    }
    
    func createTemporaryVideoFileFromAsset(asset: TrimmedVideo, completionHandlerURL: @escaping (_ tempURL: URL?) ->Void){
        
        
        let outputURL = createTemporaryURL(pathComponent: "temp_video.mp4")
        deleteTemporaryFile(outputURL)
        
        
        let compatible = AVAssetExportSession.exportPresets(compatibleWith: asset.asset)
        
        if compatible.contains("AVAssetExportPresetMediumQuality"){
            let exportSession = AVAssetExportSession(asset: asset.asset, presetName: "AVAssetExportPresetMediumQuality")
            exportSession?.outputFileType = AVFileType.mp4
            exportSession?.timeRange = CMTimeRange(start: asset.startTime, end: asset.endTime)
            exportSession?.outputURL = outputURL
            exportSession?.exportAsynchronously(completionHandler: {
                
                switch exportSession!.status{
                    
                case .failed:
                    print("failed")
                    completionHandlerURL(nil)
                    print(exportSession!.error.debugDescription)
                //print(e)
                case .completed:
                    print("nothing")
                    //self.passedURL = outputURL
                    completionHandlerURL(outputURL)
                    //AVURLAsset(url: outputURL).duration
                    //self.performSegue(withIdentifier: "EditSegue", sender: self)
                default:
                    break
                }
            })
        }
    }
    
    private func createTemporaryURL(pathComponent: String!) -> URL{
        let tempDirectory = FileManager.default.temporaryDirectory
        
        return tempDirectory.appendingPathComponent(pathComponent)
    }
    
    private func deleteTemporaryFile(_ url: URL!){
        
        if FileManager.default.fileExists(atPath: url.path){
            do{
                try FileManager.default.removeItem(atPath: url.path)
                print("Success")
            }catch{
                print("unable to delete temp file")
            }
        }
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)

        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            print("Save button tapped")
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: self.tempGifURL)
            }, completionHandler: { (saved, error) in
                guard error == nil else {return}
                
                print("Saved")
                self.deleteTemporaryFile(self.tempGifURL)
                
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)

                }
            })
            
        }
        
        alert.addAction(saveAction)
        
        alert.isSpringLoaded = true
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

