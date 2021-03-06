//
//  ViewController.swift
//  GSDeomo
//
//  Created by 石川大輔 on 2021/04/08.
//

import UIKit
import CoreData
import AVFoundation
import QuickLookThumbnailing

class ViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var contentArray = [Content]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        loadContent()
        
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("!!!!!!!!!!!!")
        print(paths)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadContent()
        tableView.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //        let newContent = Content(context: self.context)
        //        newContent.date = Date()
        //        newContent.memo = "サンプルメモ"
        //        //        self.contentArray.append(newContent)
        //                self.contentArray.insert(newContent, at: 0)
        //        self.saveContents()
        
        tableView.reloadData()
        
        self.performSegue(withIdentifier: "captureVideo", sender: self)
    }
    
    //MARK: - Model Manupulation Method
    
    func loadContent() {
        let request: NSFetchRequest<Content> = Content.fetchRequest()
        do {
            contentArray = try context.fetch(request)
            contentArray.sort{ $0.date! > $1.date!}
        } catch {
            print("Error fetching data from context \(error) ")
        }
    }
    
    func saveContents() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
}

//MARK: - TableView Datasource Methods

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        //        Load Date data from CoreData
        
        
        
        let newDate = contentArray[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        DispatchQueue.main.async {
            cell.rightBottomLabel.text = formatter.string(from: newDate!)
            cell.label.text = self.contentArray[indexPath.row].memo
        }
        
        //        Display Thumbnail
        let moviePATH = contentArray[indexPath.row].movie
        print("==================")
        print(contentArray[indexPath.row])
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = path[0]
        let movieFilePath = "\(documentDirectory)/\(moviePATH!)"
        let movieURL = URL(fileURLWithPath: movieFilePath)
        
        generateThumbnailRepresentations(url: movieURL) { (uiImageThumbnail) in


            //                    print image size
            if let image = uiImageThumbnail {
                let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
                var imageSize: Int = imgData.count
                print("======================================")
                print(String(format: "actual size of image in KB: %f ", Double(imageSize) / 1000.0))
            }


                cell.leftImageView.image = uiImageThumbnail

        }
        
        
//        createTnumbnail(url: movieURL) { (thumbImage) in
//
//
////                    print image size
//            if let image = thumbImage {
//                    let imgData = NSData(data: image.jpegData(compressionQuality: 1)!)
//                    var imageSize: Int = imgData.count
//                    print("======================================")
//                    print(String(format: "actual size of image in KB: %f ", Double(imageSize) / 1000.0))
//            }
//
//
//            cell.leftImageView.image = thumbImage
//
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            context.delete(contentArray[indexPath.row])
            contentArray.remove(at: indexPath.row)
            saveContents()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
        }
    }
    
    
    func createTnumbnail(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                completion(thumbImage)
            }
        } catch {
            print("Failure to generate cgImage \(error)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    
    func generateThumbnailRepresentations(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        let size: CGSize = CGSize(width: 30, height: 90)
        let scale = UIScreen.main.scale
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .lowQualityThumbnail)
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    print("fail to generate QLThumnail: (\(error)")
                } else {
                    // Display the thumbnail that you created.
                    let uiImageThumbnail = thumbnail?.uiImage
                    completion(uiImageThumbnail)
                }
            }
        }
    }
    
    
    
}

//MARK: - TableView Delegate Methods

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        Delete the data that you choosed
        //        context.delete(contentArray[indexPath.row])
        //        contentArray.remove(at: indexPath.row)
        //        saveContents()
        //        tableView.reloadData()
        
        
        performSegue(withIdentifier: "PlayVideo", sender: indexPath.row)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayVideo" {
            let destinationVC = segue.destination as! PlayerViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let moviePATH = contentArray[indexPath.row].movie
                destinationVC.moviePath = moviePATH
                destinationVC.selectedRow = indexPath.row
            }
        }
        
        if segue.identifier == "captureVideo" {
            let destinationVC = segue.destination as! CaptureViewController
            if !contentArray.isEmpty {
                let moviePATH = contentArray[0].movie
                destinationVC.newestMoviePath = moviePATH
            }
        }
        
    }
    
}
