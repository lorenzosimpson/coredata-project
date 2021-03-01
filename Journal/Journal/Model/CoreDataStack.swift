//
//  CoreDataStack.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//  Copyright © 2021 Lambda School. All rights reserved.
//

import Foundation
import CoreData

// this file serves as primary interface for accessing data model

class CoreDataStack {
    static let shared = CoreDataStack() // singleton
    // accessible through CoreDataStack.shared
    
    // manage NSPersistentContainer
    lazy var container: NSPersistentContainer = {
        // stored property
        let container = NSPersistentContainer(name: "Journal") // name of the xcmodel file
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores, \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(to context: NSManagedObjectContext=CoreDataStack.shared.mainContext) throws {
        var error: Error?
        context.performAndWait {
            do {
            try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
}
