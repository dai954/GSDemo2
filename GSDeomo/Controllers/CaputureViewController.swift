//
//  CaputureViewController.swift
//  GSDeomo
//
//  Created by 石川大輔 on 2021/04/22.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CoreData

class CaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    var contentArray = [Content]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // スタートボタン.
    private var myButtonStart: UIButton!
    
    // ストップボタン.
    private var myButtonStop: UIButton!
    
    // ビデオのアウトプット.
    private var myVideoOutput: AVCaptureMovieFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションの作成.
        let mySession = AVCaptureSession()
        
        // デバイス.
        var myDevice: AVCaptureDevice!
        
        // 出力先を生成.
        let myImageOutput = AVCaptureStillImageOutput()
        
        // マイクを取得.
        let audioCaptureDevice = AVCaptureDevice.devices(for: AVMediaType.audio)
        
        // マイクをセッションのInputに追加.
        let audioInput = try! AVCaptureDeviceInput.init(device: audioCaptureDevice.first!)
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックライトをmyDeviceに格納.
        for device in devices {
            if(device.position == AVCaptureDevice.Position.back){
                myDevice = device
            }
        }
        
        // バックカメラを取得.
        let videoInput = try! AVCaptureDeviceInput.init(device: myDevice)
        
        // ビデオをセッションのInputに追加.
        mySession.addInput(videoInput)
        
        // オーディオをセッションに追加.
        mySession.addInput(audioInput);
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 動画の保存.
        myVideoOutput = AVCaptureMovieFileOutput()
        
        // ビデオ出力をOutputに追加.
        mySession.addOutput(myVideoOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer = AVCaptureVideoPreviewLayer.init(session: mySession)
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        // UIボタンを作成.
        myButtonStart = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        myButtonStop = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        
        myButtonStart.backgroundColor = UIColor.red
        myButtonStop.backgroundColor = UIColor.gray
        
        myButtonStart.layer.masksToBounds = true
        myButtonStop.layer.masksToBounds = true
        
        myButtonStart.setTitle("撮影", for: .normal)
        myButtonStop.setTitle("停止", for: .normal)
        
        myButtonStart.layer.cornerRadius = 20.0
        myButtonStop.layer.cornerRadius = 20.0
        
        myButtonStart.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height-50)
        myButtonStop.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)
        
        myButtonStart.addTarget(self, action: #selector(CaptureViewController.onClickMyButton), for: .touchUpInside)
        myButtonStop.addTarget(self, action: #selector(CaptureViewController.onClickMyButton), for: .touchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButtonStart);
        self.view.addSubview(myButtonStop);
    }
    
    
    /*
     ボタンイベント.
     */
    @objc internal func onClickMyButton(sender: UIButton){
        
        // 撮影開始.
        if( sender == myButtonStart ){
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            // フォルダ.
            let documentsDirectory = paths[0]
            
            // ファイル名.
            let filePath = "\(documentsDirectory)/test.mp4"
            
            // URL.
            let fileURL = URL(fileURLWithPath: filePath)
            
            // 録画開始.
            myVideoOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
        // 撮影停止.
        else if ( sender == myButtonStop ){
            myVideoOutput.stopRecording()
            
            let newContent = Content(context: self.context)
            newContent.date = Date()
            newContent.memo = "サンプルメモ"
            //        self.contentArray.append(newContent)
            self.contentArray.insert(newContent, at: 0)
            self.saveContents()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    /*
     動画のキャプチャーが終わった時に呼ばれるメソッド.
     */
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        //AssetsLibraryを生成する.
        let assetsLib = ALAssetsLibrary()
        
        //動画のパスから動画をフォトライブラリに保存する.
        assetsLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL, completionBlock: nil)    }
    
    
    //MARK: - Model Manupulation Method
    func saveContents() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
}
