//
//  EntryRepresentation.swift
//  Journal
//
//  Created by Lorenzo on 2/23/21.
//

import Foundation

struct EntryRepresentation: Codable {
    var title: String
    var bodyText: String
    var timestamp: Date
    var id: String
    var mood: String
}
