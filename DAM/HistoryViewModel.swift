//
//  HistoryViewModel.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

/*import Foundation
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
    
    private let baseURL = "http://192.168.137.103:3001/history" // Remplacez par l'URL de votre API réelle
    
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
}*/


import SwiftUI
import Combine

// Vue de l'historique
struct HistoryView: View {
    @ObservedObject var viewModel = HistoryViewModel()

    // Fonction pour décoder l'image base64
    func decodeBase64ToImage(base64String: String) -> Image? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    var body: some View {
        VStack {
            // Si l'utilisateur n'a pas de jeton d'accès, afficher un message
            if viewModel.historyList.isEmpty {
                Text("Veuillez vous connecter pour voir l'historique.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(viewModel.historyList, id: \.id) { historyItem in  // Utilisez 'id' comme identifiant unique
                    VStack(alignment: .leading) {
                        // Affichage de l'image si elle existe
                        if let imageBase64 = historyItem.image,
                           let image = decodeBase64ToImage(base64String: imageBase64) {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())  // Exemple de forme de l'image
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 5)
                        }
                        
                        // Description de l'historique
                        Text(historyItem.description)
                            .font(.headline)
                            .padding(.top, 8)
                        Text(historyItem.date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 10)  // Espace entre chaque élément de la liste
                }
                .onAppear {
                    viewModel.fetchHistory()
                }
            }
        }
        .navigationTitle("Historique")
    }
}

// ViewModel pour gérer l'historique
class HistoryViewModel: ObservableObject {
    @Published var historyList: [HistoryItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHistory() {
        // Vérifier si le jeton d'accès est présent
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            self.historyList = []  // Liste vide si pas de jeton
            return
        }

        guard let url = URL(string: "http://172.18.8.47:3001/history") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Requête pour récupérer l'historique
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [HistoryItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Erreur lors de la récupération de l'historique : \(error)")
                    self.historyList = []  // Liste vide en cas d'erreur
                }
            } receiveValue: { historyItems in
                self.historyList = historyItems
            }
            .store(in: &cancellables)
    }
}
