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
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    var moviePath: String?
    
    var slowMotionOnOff: Bool = true
    
    private var timeObserverToken: Any?
    
    private var playerTimeControllStatusObserver: NSKeyValueObservation?
    
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    //MARK: - IBOutlet properties
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var startTimeLabel: UILabel!
                            
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var errorText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = path[0]
        let movieFilePath = "\(documentDirectory)/\(moviePath!)"
        let movieURL = URL(fileURLWithPath: movieFilePath)
        
        let asset = AVAsset(url: movieURL)
        
        playAVAssetItem(forAsset: asset)
        
//        To watch video's fps
        let tracks = asset.tracks(withMediaType: .video)
        let fps = tracks.first?.nominalFrameRate
        print("-----------------------------------------")
        print(fps!)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func togglePlay(_ sender: UIButton) {
        switch player.timeControlStatus {
        case .playing:
            player.pause()
        case .paused:
            let currentItem = player.currentItem
            if currentItem?.currentTime() == currentItem?.duration {
                currentItem?.seek(to: .zero, completionHandler: nil)
            }
            print("---------------------------------------")
            print(currentItem?.canPlaySlowForward ?? false)
            
            if slowMotionOnOff {
                player.rate = 1.0
            } else {
                player.rate = 0.5
            }
        default:
            player.pause()
        }
    }
    
    
    @IBAction func slowButtonPressed(_ sender: UIButton) {
        if slowMotionOnOff {
            slowMotionOnOff = false
            sender.tintColor = .red
        } else {
            slowMotionOnOff = true
            sender.tintColor = .gray
        }
    }
    
    
    
    @IBAction func timeSliderDidChanged(_ sender: UISlider) {
        player.pause()
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
        
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
    }
    
    
    func playAVAssetItem(forAsset newAsset: AVAsset) {
        
        DispatchQueue.main.async {
            self.setupPlayerObservers()
        
            self.playerView.player = self.player
            
            self.player.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
            
        }
        
    }
    
    func setupPlayerObservers() {
        playerTimeControllStatusObserver = player.observe(\AVPlayer.timeControlStatus, options: [.initial, .new]) { [weak self] _, _  in
            DispatchQueue.main.async {
                self?.setPlayPauseButtonImage()
            }
        }
        
        let interval = CMTime(value: 1, timescale: 20)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [unowned self] (time) in
            let timeElapsed = Float(time.seconds)
            self.timeSlider.value = timeElapsed
            self.startTimeLabel.text = self.createTimeString(time: timeElapsed)
        })
        
        playerItemStatusObserver = player.observe(\AVPlayer.currentItem?.status, options: [.new, .initial]) { [unowned self] _, _ in
            DispatchQueue.main.async {
                self.updateUIforPlayerItemStatus()
            }
        }
    }
    
    func updateUIforPlayerItemStatus() {
        guard let currentItem = player.currentItem else { return }
        
        switch currentItem.status {
        case .failed:
            playPauseButton.isEnabled = false
            timeSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
            handleErrorWithMessage(currentItem.error?.localizedDescription ?? "", error: currentItem.error)
        
        case .readyToPlay:
            playPauseButton.isEnabled = true
            let newDurationSeconds = Float(currentItem.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))
            
            timeSlider.maximumValue = newDurationSeconds
            timeSlider.value = currentTime
            timeSlider.isEnabled = true
            startTimeLabel.isEnabled = true
            startTimeLabel.text = createTimeString(time: currentTime)
            durationLabel.isEnabled = true
            durationLabel.text = createTimeString(time: newDurationSeconds)

        default:
            playPauseButton.isEnabled = false
            timeSlider.isEnabled = false
            startTimeLabel.isEnabled = false
            durationLabel.isEnabled = false
        }
    }
    
    
    func setPlayPauseButtonImage() {
        var buttonImage: UIImage?
        
        switch self.player.timeControlStatus {
        case .playing:
            buttonImage = UIImage(systemName: "pause.fill")
        case .paused:
            buttonImage = UIImage(systemName: "play.fill")
        default:
            buttonImage = UIImage(systemName: "pause.fill")
        }
        
        guard  let image = buttonImage else { return }
        self.playPauseButton.setImage(image, for: .normal)
        
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    //MARK: - Error Handling
    func handleErrorWithMessage(_ message: String, error: Error? = nil) {
        if let err = error {
            print("Error occurred with message: \(message), error: \(err).")
        }
        
        let alertTitle = NSLocalizedString("Error", comment: "Alert title for errors")
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let alertActionTitle = NSLocalizedString("OK", comment: "OK on error alert")
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}
