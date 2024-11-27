//
//  User.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import Foundation
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    
    // Initialisateur optionnel pour le décodage
    init(id: String, name: String, email: String, phone: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
    }
}
