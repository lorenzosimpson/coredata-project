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
    
    
    var entryRepresentation: EntryRepresentation? {
        guard let title = title,
              let bodyText = bodyText,
              let timestamp = timestamp,
              let mood = mood else { return nil }
        
        
        return EntryRepresentation(title: title, bodyText: bodyText, timestamp: timestamp, id: id?.uuidString ?? "", mood: mood)
    }
    
    @discardableResult convenience init(title: String, bodyText: String, timestamp: Date, id: UUID=UUID(), context: NSManagedObjectContext=CoreDataStack.shared.mainContext, mood: Mood) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.id = id
        self.mood = mood.rawValue
    }
    
    
    @discardableResult convenience init?(representation: EntryRepresentation, context: NSManagedObjectContext=CoreDataStack.shared.mainContext) {
        guard let mood = Mood(rawValue: representation.mood),
              let id = UUID(uuidString: representation.id) else { return nil }
        
        self.init(title: representation.title,
                  bodyText: representation.bodyText,
                  timestamp: representation.timestamp,
                  id: id,
                  context: context,
                  mood: mood)
    }
}
