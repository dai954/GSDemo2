//
//  VideoViewController.swift
//  GSDeomo
//
//  Created by 石川大輔 on 2021/04/08.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    private let player = AVPlayer()
    var moviePath: String?
    
    //MARK: - IBOutlet properties
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = path[0]
        let movieFilePath = "\(documentDirectory)/\(moviePath!)"
        let movieURL = URL(fileURLWithPath: movieFilePath)
        
        let asset = AVAsset(url: movieURL)
        
        playAVAssetItem(forAsset: asset)
        
       
    }
    
    
    
    
    @IBAction func togglePlay(_ sender: UIButton) {
        player.play()
    }
    
    
    func playAVAssetItem(forAsset newAsset: AVAsset) {
    
        
        DispatchQueue.main.async {
            
            
            
            self.playerView.player = self.player
            
            self.player.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
           
        }
        
    }


}
