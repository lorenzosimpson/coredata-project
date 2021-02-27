//
//  EntryController.swift
//  Journal
//
//  Created by Lorenzo on 2/24/21.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case badResponse
    case failedEncode
    case failedDecode
    case otherError
    case noID
    case noData
}

class EntryController {
    let baseURL = URL(string: "https://journal-277a4-default-rtdb.firebaseio.com/")!
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    
    init() {
        fetchEntriesFromServer()
    }
    
    // SEND TASK
    func sendEntryToServer(entry: Entry, completion: @escaping CompletionHandler = {_ in }) {
        guard let id = entry.id else {
            NSLog("no id found for entry \(entry)")
            completion(.failure(.noID))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(id.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(entry.entryRepresentation)
        } catch {
            NSLog("failed to encode entry, \(error)")
            completion(.failure(.failedEncode))
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("error sending task to server, \(error)")
                completion(.failure(.otherError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                  response.statusCode != 200  {
                NSLog("Bad response, \(response.statusCode)")
                completion(.failure(.badResponse))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from PUT request")
                completion(.failure(.noData))
                return
            }
            
            completion(.success(true))
     
        }.resume()
    }
    
    // DELETE TASK
    func deleteTaskFromServer(with entry: Entry, completion: @escaping CompletionHandler = {_ in}) {
        guard let id = entry.id else {
            NSLog("no id found for entry \(entry)")
            completion(.failure(.noID))
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(id.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                NSLog("error deleting task from server, \(error)")
                completion(.failure(.otherError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                  response.statusCode != 200  {
                NSLog("Bad response, \(response.statusCode)")
                completion(.failure(.badResponse))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    // UPDATE
    func update(with entry: Entry, representation: EntryRepresentation) {
        entry.id = UUID(uuidString: representation.id)
        entry.title = representation.title
        entry.bodyText = representation.bodyText
        entry.timestamp = representation.timestamp
        entry.mood = representation.mood
    }
    
    
    // UPDATE ENTRIES RETRIEVED FROM FIREBASE
    func updateEntries(with representations: [EntryRepresentation]) {
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.id)})
        var representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
        
        do {
           let existingEntries = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            for entry in existingEntries {
                guard let id = entry.id,
                      let representation = representationsByID[id] else { continue }
                self.update(with: entry, representation: representation)
                representationsByID.removeValue(forKey: id)
            }
            let context = CoreDataStack.shared.mainContext
            for representation in representationsByID.values {
                Entry(representation: representation, context: context)
            }
            try context.save()
        } catch {
            NSLog("Error updating entries to representations, \(error)")
            return
        }
        
 
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = {_ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL, completionHandler: { (data, response, error) in
            if let error = error {
                NSLog("Error fetching entries from server, \(error)")
                completion(.failure(.otherError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
                NSLog("Bad response from server: \(response.statusCode)")
                completion(.failure(.badResponse))
                return
            }
            
            guard let data = data else {
                NSLog("no data returned from fetch request")
                completion(.failure(.noData))
                return
            }
            // Decode
            do {
                var fetchedEntries: [EntryRepresentation] = []
                fetchedEntries = Array(try JSONDecoder().decode([String: EntryRepresentation].self, from: data).values)
                self.updateEntries(with: fetchedEntries)
                completion(.success(true))
            } catch {
                
            }
            
        }).resume()
    }
}
