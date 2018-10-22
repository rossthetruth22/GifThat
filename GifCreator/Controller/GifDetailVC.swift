//
//  GifDetailVC.swift
//  GifCreator
//
//  Created by Royce Reynolds on 8/5/18.
//  Copyright © 2018 Royce Reynolds. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GifDetailVC: UIViewController {
    
    var detailGif: FLAnimatedImage!
    
    @IBOutlet weak var detailView: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailView.animatedImage = detailGif
    }
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer){
//        let isDraggingDown = (recognizer.velocity(in: view).y > 0)
//        
//        
//        switch recognizer.state{
//        case .began:
//            print("began")
//        case .changed:
//            if let view = recognizer.view{
//                view.center.y = view.center.y + recognizer.translation(in: view).y
//                recognizer.setTranslation(CGPoint.zero, in: view)
//            }
//            
//            print("changed")
//        case .ended:
//            print("ended")
//        default:
//            break
//        }
    }
    
    @IBAction func handleTaps(_ recognizer: UITapGestureRecognizer){
        
        switch recognizer.state{
        case .ended:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
        
    }
    
 
    @IBAction func presentActivityController(_ sender: Any) {
        //let image = UIImage(data: detailGif.data)
        let image = detailGif.data
        let activityVC = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
