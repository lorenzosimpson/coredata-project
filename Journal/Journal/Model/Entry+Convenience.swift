//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//

import Foundation
import CoreData

extension Entry {
    @discardableResult convenience init(title: String, bodyText: String, timestamp: Date, id: UUID=UUID(), context: NSManagedObjectContext=CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.id = id
    }
}
