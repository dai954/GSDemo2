//
//  MemoViewController.swift
//  GSDeomo2
//
//  Created by 石川大輔 on 2021/05/29.
//

import UIKit
import CoreData

class MemoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var selectedRow: Int?
    
    private var contentArray = [Content]()
    
    override func viewDidLoad() {
        
        textView.layer.borderWidth = 1.0
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadContent()
        DispatchQueue.main.async {
            self.textView.text = self.contentArray[self.selectedRow!].memo
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let text = self.textView.text {
            print(text)
            contentArray[selectedRow!].memo = text
            saveContents()
        }
        
    }
    
    @IBAction func saveButtonPressec(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manupulation Method
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
