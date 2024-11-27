//
//  EditProfileView.swift
//  DAM
//
//  Created by Apple Esprit on 27/11/2024.
//

import Foundation
import SwiftUI

struct EditProfileView: View {
    @State var user: User
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Text("Édition du profil pour \(user.name ?? "Nom non disponible")")
                .font(.title)
                .padding(.top)
            
            Form {
                // Nom
                Section(header: Text("Nom")) {
                    TextField("Nom", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            name = user.name ?? ""
                        }
                }
                
                // Email
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            email = user.email ?? ""
                        }
                }
                
                // Téléphone
                Section(header: Text("Téléphone")) {
                    TextField("Téléphone", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            phone = user.phone ?? ""
                        }
                }
                
                // Mot de passe
                Section(header: Text("Mot de passe")) {
                    SecureField("Nouveau mot de passe", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Confirmer le mot de passe", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                // Bouton de sauvegarde
                Section {
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Sauvegarder")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().fill(Color.blue))
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Modifier le profil")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveProfile() {
        isLoading = true
        errorMessage = nil
        
        // Vérification des champs
        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty else {
            errorMessage = "Tous les champs doivent être remplis."
            isLoading = false
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Les mots de passe ne correspondent pas."
            isLoading = false
            return
        }
        
        // Créer le dictionnaire des données à envoyer
        var profileData = [
            "name": name,
            "email": email,
            "phone": phone
        ]
        
        if !password.isEmpty {
            profileData["password"] = password
        }
        
        updateProfile(with: profileData)
    }
    
    private func updateProfile(with data: [String: String]) {
        guard let url = URL(string: "http://172.18.8.47:3001/profile") else {
            errorMessage = "URL invalide."
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Ajouter le token dans les en-têtes
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encoder les données en JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Erreur lors de la création des données : \(error.localizedDescription)"
            isLoading = false
            return
        }
        
        // Effectuer la requête
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Erreur lors de la mise à jour du profil : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de la mise à jour du profil."
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Aucune donnée reçue."
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Réponse brute de l'API : \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    // Mise à jour réussie, revenir en arrière ou afficher une confirmation
                    print("Profil mis à jour avec succès.")
                    // Vous pouvez également mettre à jour localement les données du profil ici si nécessaire.
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors de la mise à jour du profil."
                }
            }
        }.resume()
    }
}



