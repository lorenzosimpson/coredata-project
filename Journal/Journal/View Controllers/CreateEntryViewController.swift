//
//  CreateEntryViewController.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//

import UIKit

class CreateEntryViewController: UIViewController {
    
    // MARK: IB Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextTextField: UITextView!
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        if let title = titleTextField.text,
           !title.isEmpty,
           let bodyText = bodyTextTextField.text,
           !bodyText.isEmpty {
            
            Entry(title: title, bodyText: bodyText, timestamp: Date())
            let moc = CoreDataStack.shared.mainContext
            do {
                try moc.save()
                navigationController?.dismiss(animated: true, completion: nil)
            } catch {
                print("error saving journal entry to MOC, \(error)")
            }
            
        } else {
            // error
            let alert = UIAlertController(title: "Failed to save entry", message: "Please try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    

}
