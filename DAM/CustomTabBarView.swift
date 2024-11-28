import SwiftUI

struct CustomTabBarView: View {
    @State private var isLoggedOut = false  // Flag pour vérifier la déconnexion
    @State private var selectedTab = "Accueil"
    
    var body: some View {
        TabView {
            Text("Accueil")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            Text("Boutique")
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
            Text("Historique")
                .tabItem {
                    Image(systemName: "clock")
                    // Text("Historique")
                }
            ProfileControllerView(isLoggedOut: $isLoggedOut)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profil")
                }
        }
        .navigationTitle(selectedTab) // Change dynamiquement selon l'onglet
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(.blue) // Couleur de l'onglet sélectionné
    }
    
    struct ProfileControllerView: View {
        @State private var userProfile: User? // Modèle utilisateur
        @State private var isLoading = true // Indicateur de chargement
        @State private var hasError = false // Indicateur d'erreur
        @Binding var isLoggedOut: Bool // Pour gérer la déconnexion
        @State private var isDarkMode = false // Variable pour gérer le mode sombre

        var body: some View {
            VStack {
                if isLoading {
                    ProgressView("Chargement...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                } else if hasError {
                    Text("Impossible de charger le profil utilisateur.")
                        .foregroundColor(.red)
                        .padding()
                } else if let profile = userProfile {
                    VStack {
                        // Affichage de l'image de profil
                        Image("user") // Remplacez par l'image dans vos assets
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)

                        // Nom d'utilisateur
                        Text(profile.name ?? "Nom d'utilisateur")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    
                    // Détails utilisateur
                    VStack(alignment: .center, spacing: 10) {
                        ProfileDetailRow(icon: "envelope", text: profile.email ?? "Email non disponible")
                        ProfileDetailRow(icon: "phone", text: profile.phone ?? "Téléphone non disponible")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Boutons
                    VStack(spacing: 20) {
                        // Bouton Modifier le profil
                        if let userProfile = userProfile {
                            NavigationLink(destination: EditProfileView(user: userProfile)) {
                                VStack {
                                    Text("Modifier le profil")
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            }
                        }
                        // Carte Dark Mode
                        Button(action: {
                            isDarkMode.toggle()
                            // Bascule entre les modes clair et sombre
                            UIApplication.shared.windows.first?.rootViewController?.view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                        }) {
                            VStack {
                                Text(isDarkMode ? "Passer en mode clair" : "Passer en mode Dark")
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .green : .black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                        }
                    }
                        
                        // Bouton Déconnexion
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "accessToken")
                            UserDefaults.standard.removeObject(forKey: "refreshToken")
                            isLoggedOut = true
                        }) {
                            VStack {
                                Text("Déconnexion")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                        }

                    // Terms and Conditions Link
                    Text("Terms and Conditions")
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            if let url = URL(string: "https://www.freeprivacypolicy.com/live/6bcf6418-363a-4e43-9e76-2a51080fb704") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .padding(.top, 20)
                }
            }
            .onAppear {
                fetchUserProfile()
            }
        }

        private func fetchUserProfile() {
            isLoading = true
            hasError = false
            
            guard let url = URL(string: "http://172.18.8.47:3001/profile") else {
                print("URL invalide.")
                hasError = true
                isLoading = false
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Ajouter le token dans les en-têtes
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                }
                
                if let error = error {
                    print("Erreur lors de la requête : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        hasError = true
                    }
                    return
                }
                
                guard let data = data else {
                    print("Aucune donnée reçue.")
                    DispatchQueue.main.async {
                        hasError = true
                    }
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse brute de l'API : \(responseString)")
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Erreur: Statut HTTP non 200. Code : \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        hasError = true
                    }
                    return
                }
                
                do {
                    let decodedProfile = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.userProfile = decodedProfile
                    }
                } catch {
                    print("Erreur de déchiffrement JSON : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        hasError = true
                    }
                }
            }.resume()
        }
    }

    struct ProfileDetailRow: View {
        let icon: String
        let text: String

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24) // Ajuster la taille de l'icône si nécessaire
                Text(text)
                    .foregroundColor(.black)
                    .padding(.leading, 5)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)  // Centrer horizontalement le contenu
            .padding(.vertical, 5)
        }
    }

    
}



