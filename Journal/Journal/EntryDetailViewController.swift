//
//  EntryDetailViewController.swift
//  Journal
//
//  Created by Lorenzo on 2/19/21.
//

import UIKit

class EntryDetailViewController: UIViewController {

    
    var entry: Entry?
    var wasEdited: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        updateViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if wasEdited {
           guard let newTitle = titleTextField.text,
                 !newTitle.isEmpty,
                 let entry = entry else { return }
            entry.title = newTitle
            entry.bodyText = noteTextView.text
            let newMoodIndex = moodSegmentedControl.selectedSegmentIndex
            entry.mood = Mood.allCases[newMoodIndex].rawValue
            
        
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving changes to MOC, \(error)")
            }
        }
    }
    
    private func updateViews() {
        titleTextField.text = entry?.title
        titleTextField.isUserInteractionEnabled = isEditing
        
        noteTextView.text = entry?.bodyText
        noteTextView.isUserInteractionEnabled = isEditing
        
        let mood: Mood
        if let entryMood = entry?.mood {
            mood = Mood(rawValue: entryMood)!
        } else {
            mood = .neutral
        }
        moodSegmentedControl.selectedSegmentIndex = Mood.allCases.firstIndex(of: mood) ?? 1
        moodSegmentedControl.isUserInteractionEnabled = isEditing
    }
    
    // MARK: IB outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var moodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var noteTextView: UITextView!
    
    
   // MARK: Editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            wasEdited = true
        }
        titleTextField.isUserInteractionEnabled = editing
        noteTextView.isUserInteractionEnabled = editing
        moodSegmentedControl.isUserInteractionEnabled = editing
        navigationItem.hidesBackButton = editing
    }

}
