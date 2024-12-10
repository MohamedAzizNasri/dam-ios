//
//  HistoryItem.swift
//  DAM
//
//  Created by Apple Esprit on 1/12/2024.
import Foundation



// Modèle pour un élément historique
struct HistoryItem: Codable {
    let id: Int    // Ajouter id si le serveur le retourne
    let image: String?  // Peut être nil si l'image n'est pas présente
    let description: String
    let date: String
}


