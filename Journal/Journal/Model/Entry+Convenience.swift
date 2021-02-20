//
//  Entry+Convenience.swift
//  Journal
//
//  Created by Lorenzo on 2/18/21.
//

import Foundation
import CoreData

enum Mood: String, CaseIterable {
    case happy
    case neutral
    case sad
}

extension Entry {
    @discardableResult convenience init(title: String, bodyText: String, timestamp: Date, id: UUID=UUID(), context: NSManagedObjectContext=CoreDataStack.shared.mainContext, mood: Mood) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.id = id
        self.mood = mood.rawValue
    }
}
