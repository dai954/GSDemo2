//
//  ViewController.swift
//  GSDeomo
//
//  Created by 石川大輔 on 2021/04/08.
//

import UIKit
import CoreData
import AVFoundation

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
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = path[0]
        let movieFilePath = "\(documentDirectory)/\(moviePATH!)"
        let movieURL = URL(fileURLWithPath: movieFilePath)
//        if let thumbnail = createTnumbnail(url: movieURL) {
//            DispatchQueue.main.async {
//                cell.leftImageView.image = thumbnail
//            }
//        }
        
        createTnumbnail(url: movieURL) { (thumbImage) in
            cell.leftImageView.image = thumbImage
        }
        
        return cell
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
    
//    func createTnumbnail(url: URL) -> UIImage? {
//
//        do {
//            let asset = AVAsset(url: url)
//            let imageGenerator = AVAssetImageGenerator(asset: asset)
//            imageGenerator.appliesPreferredTrackTransform = true
//            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
//            return UIImage(cgImage: cgImage)
//        } catch {
//            print("Failure to generate cgImage \(error)")
//            return nil
//        }
//    }
    
}

//MARK: - TableView Delegate Methods

private var contentIndex: Int?

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        contentIndex = indexPath.row
        performSegue(withIdentifier: "PlayVideo", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayVideo" {
            let destinationVC = segue.destination as! PlayerViewController
            let moviePATH = contentArray[contentIndex!].movie
            destinationVC.moviePath = moviePATH
        }
    }
    
}
