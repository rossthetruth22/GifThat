//
//  VideoCutter.swift
//  GifCreator
//
//  Created by Royce Reynolds on 9/3/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import YGCTrimVideoView
import PryntTrimmerView

class VideoCutter: UIViewController {
    
    var asset: PHAsset!
    var pictureService: PhotoService!
    private var playerItem: AVPlayerItem!
    private var playerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    private var playerLooper: AVPlayerLooper!
    private var queuePlayer: AVQueuePlayer!
    private var timeObserverToken: Any?
    @IBOutlet weak var videoView: UIView!
    var url: URL!
    var passedURL: URL!
    @IBOutlet weak var trimmerView: TrimmerView!
    //@IBOutlet weak var videoTrimmer: YGCTrimVideoView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let width = videoTrimmer.frame.width
//        let height = videoTrimmer.frame.height
//        let origin = videoTrimmer.frame.origin
//        let size = CGSize(width: width, height: height)
//        videoTrimmer = YGCTrimVideoView(frame: CGRect(origin: origin, size: size), assetURL: url)
//        videoTrimmer.delegate = self
//        view.addSubview(videoTrimmer)
        let width = trimmerView.frame.width
        let height = trimmerView.frame.height
        let origin = trimmerView.frame.origin
        let size = CGSize(width: width, height: height)
        
        trimmerView.frame = CGRect(origin: origin, size: size)
        trimmerView.mainColor = UIColor(red: 1, green: 0.8353, blue: 0.0392, alpha: 1.0)
        trimmerView.delegate = self
        trimmerView.minDuration = 1
        trimmerView.asset = AVAsset(url: url)
        view.addSubview(trimmerView)
        
        playerItem = AVPlayerItem(url: url)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        print("Start time: \(trimmerView.startTime!)")
        print("End time: \(trimmerView.endTime!)")
        
        guard let startTime = trimmerView.startTime else {return}
        guard let endTime = trimmerView.endTime else {return}
        let maxDuration = trimmerView.maxDuration
        
        
        
        let timeValue:CMTimeValue  = CMTimeGetSeconds(endTime) > maxDuration ? CMTimeValue(Int32(maxDuration) * endTime.timescale) : endTime.value
        
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem, timeRange: CMTimeRange(start: CMTime(value: startTime.value, timescale: startTime.timescale), end: CMTime(value: timeValue, timescale: endTime.timescale)))
        playerLooper = looper
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
        addPeriodicTimeObserver()
        queuePlayer.play()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = trimmerView.frame.width
        let height = trimmerView.frame.height
        let origin = trimmerView.frame.origin
        let size = CGSize(width: width, height: height)
        trimmerView.frame = CGRect(origin: origin, size: size)
        
        trimmerView.mainColor = UIColor(red: 1, green: 0.8353, blue: 0.0392, alpha: 1.0)
        trimmerView.delegate = self
        
        trimmerView.asset = AVAsset(url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setUpAVPlayer(asset: AVAsset){
        playerItem = AVPlayerItem(asset: asset)
    }
    
    func addPeriodicTimeObserver(){
        //queuePlayer.removeTimeObserver(timeObserverToken)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        let mainQueue = DispatchQueue.main
        
        timeObserverToken = queuePlayer.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self](currentTime) in
            self?.trimmerView.seek(to: currentTime)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue"{
            if let destination = segue.destination as? VideoEditingVC{
                //destination.videoURL = passedURL
                guard let asset = queuePlayer.items().first?.asset else {return}
                guard let startTime = trimmerView.startTime else {return}
                guard let endTime = trimmerView.endTime else {return}
                destination.importAsset = TrimmedVideo(asset: asset, startTime: startTime, endTime: endTime)
            }
        }
    }
    
    @IBAction func createGif(_ sender: Any) {
        
        self.queuePlayer.pause()
        
//        let compatible = AVAssetExportSession.exportPresets(compatibleWith: (queuePlayer.items().first?.asset)!)
//        
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let outputURL = tempDirectory.appendingPathComponent("temp_video.mp4")
//        
//        if FileManager.default.fileExists(atPath: outputURL.path){
//            do{
//                try FileManager.default.removeItem(atPath: outputURL.path)
//                print("Success")
//            }catch{
//                print("unable to delete temp file")
//            }
//        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "EditSegue", sender: self)
        }
        
        
//        if compatible.contains("AVAssetExportPresetMediumQuality"){
//            let exportSession = AVAssetExportSession(asset: (queuePlayer.items().first?.asset)!, presetName: "AVAssetExportPresetMediumQuality")
//            exportSession?.outputFileType = AVFileType.mp4
//            exportSession?.timeRange = CMTimeRange(start: trimmerView.startTime!, end: trimmerView.endTime!)
//            exportSession?.outputURL = outputURL
//            exportSession?.exportAsynchronously(completionHandler: {
//
//                switch exportSession!.status{
//
//                case .failed:
//                    print("failed")
//                    print(exportSession!.error.debugDescription)
//                    //print(e)
//                case .completed:
//                    self.passedURL = outputURL
//                    //AVURLAsset(url: outputURL).duration
//                    print("File duration: \(AVURLAsset(url: outputURL).duration)")
//                    //self.performSegue(withIdentifier: "EditSegue", sender: self)
//                    print("completed bih!")
//                    DispatchQueue.main.async {
//                        self.performSegue(withIdentifier: "EditSegue", sender: self)
//                    }
//
//                default:
//                    break
//                }
//            })
//
//        }
    }

}

extension VideoCutter: YGCTrimVideoViewDelegate{
    func videoBeginTimeChanged(_ begin: CMTime) {
        if self.queuePlayer.currentItem != self.playerItem{
            queuePlayer.replaceCurrentItem(with: playerItem)
        }
        
        queuePlayer.seek(to: begin)
    }
    
    func videoEndTimeChanged(_ end: CMTime) {
        if self.queuePlayer.currentItem != self.playerItem{
            queuePlayer.replaceCurrentItem(with: playerItem)
        }
        
        queuePlayer.seek(to: end)
    }
    
    func dragActionEnded(_ asset: AVMutableComposition!) {
        playerItem = AVPlayerItem(asset: asset)
        queuePlayer.removeAllItems()
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        //queuePlayer.replaceCurrentItem(with: playerItem)
        print("Queue player count: \(queuePlayer.items().count)")
        queuePlayer.play()
    }
    
    
}

extension VideoCutter: TrimmerViewDelegate{
    func didChangePositionBar(_ playerTime: CMTime) {
    
        queuePlayer.pause()
        queuePlayer.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        
        queuePlayer.removeAllItems()
        queuePlayer.removeTimeObserver(timeObserverToken)
        queuePlayer = AVQueuePlayer(playerItem: AVPlayerItem(url: url))
        playerLayer.player = queuePlayer
        addPeriodicTimeObserver()
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem, timeRange: CMTimeRange(start: trimmerView.startTime!, end: trimmerView.endTime!))
        playerLooper = looper
        queuePlayer.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        queuePlayer.play()
         
    }
    

}
