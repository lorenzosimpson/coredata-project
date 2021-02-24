//
//  EntryController.swift
//  Journal
//
//  Created by Lorenzo on 2/24/21.
//

import Foundation

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
}
