//
//  EntryTableViewController.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//

import UIKit
import CoreData

class EntryTableViewController: UITableViewController {
    
    // MARK: Properties
    var entryController = EntryController()
    var entries: [Entry] {
        let context = CoreDataStack.shared.mainContext
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching entries from MOC, \(error)")
            return []
        }
    }
    
    static let reuseIdentifier = "EntryCell"
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: moc,
                                                           sectionNameKeyPath: "mood",
                                                           cacheName: nil)
        fetchedController.delegate = self
        do {
            try fetchedController.performFetch()
        } catch {
            print("Error fetching entries with NSFetchedResultsController, \(error)")
        }
        
        return fetchedController
    }()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EntryDetailSegue" {
            guard let detailVC = segue.destination as? EntryDetailViewController else { return }
            if let indexPath = tableView.indexPathForSelectedRow {
            detailVC.entry = fetchedResultsController.object(at: indexPath)
                detailVC.entryController = entryController
            }
        } else if segue.identifier == "CreateEntryModalSegue" {
            guard let navC = segue.destination as? UINavigationController,
                  let createEntryVC = navC.viewControllers.first as? CreateEntryViewController else { return }
            createEntryVC.entryController = entryController
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewCell.reuseIdentifier, for: indexPath) as? EntryTableViewCell else { fatalError("can't dequeue cell of type \(EntryTableViewCell.reuseIdentifier)")}

        cell.entry = fetchedResultsController.object(at: indexPath)
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entryToDelete = fetchedResultsController.object(at: indexPath)
            
            entryController.deleteTaskFromServer(with: entryToDelete) { result in
                // did the deletion from the server succeed?
                guard let _ = try? result.get() else { return }
                
                let context = CoreDataStack.shared.mainContext
                context.delete(entryToDelete)
                do {
                    try context.save()
                } catch {
                    print("Error deleting item, \(error)")
                }
            }
        }
    }
    
    
}

extension EntryTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates() // put table into editing mode
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates() // done making changes
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}
