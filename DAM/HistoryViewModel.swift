//
//  HistoryViewModel.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import Foundation
import SwiftUI
import Combine

// Structure pour la réponse d'historique
struct HistoryItem: Codable {
    let id: Int
    let description: String
    let date: String
}

// ViewModel en Swift pour gérer l'historique
class HistoryViewModel: ObservableObject {
    private let tokenPreferenceManager = TokensPreferenceManager()
    private let historyService = HistoryService()
    
    // Liste d'historique observable
    @Published var historyList: [HistoryItem] = []
    
    // Récupérer le token d'accès
    private func getAccessToken() -> String? {
        let token = tokenPreferenceManager.getToken()
        print("Access token: \(token ?? "Not available")")
        return token
    }
    
    // Initialisation, récupère l'historique
    init() {
        getHistory()
    }
    
    // Fonction pour récupérer l'historique
    func getHistory() {
        guard let token = getAccessToken(), !token.isEmpty else {
            print("Token is not available")
            return
        }
        
        // Effectuer l'appel API pour récupérer l'historique
        historyService.getAllHistory(token: "Bearer \(token)") { result in
            switch result {
            case .success(let historyItems):
                print("Fetched history: \(historyItems)")
                DispatchQueue.main.async {
                    self.historyList = historyItems
                }
            case .failure(let error):
                print("Failed to fetch history: \(error.localizedDescription)")
            }
        }
    }
}

// Service pour effectuer les appels API
class HistoryService {
    
    private let baseURL = "http://172.18.8.47:3000/history" // Remplacez par l'URL de votre API réelle
    
    // Fonction pour récupérer l'historique via l'API
    func getAllHistory(token: String, completion: @escaping (Result<[HistoryItem], Error>) -> Void) {
        // URL pour l'appel API
        guard let url = URL(string: "\(baseURL)/history") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        // Effectuer la requête réseau
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let historyItems = try decoder.decode([HistoryItem].self, from: data)
                completion(.success(historyItems))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Gestion des tokens d'authentification (simplifié ici avec UserDefaults)
class TokensPreferenceManager {
    
    private let tokenKey = "accessToken"
    
    // Fonction pour obtenir le token
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    // Fonction pour sauvegarder le token
    func saveToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: tokenKey)
    }
}
