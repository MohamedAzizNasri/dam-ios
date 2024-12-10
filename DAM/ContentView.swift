/*import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var resultText: String = "Résultat : Aucun"
    @State private var showImagePicker = false
    @State private var isLoading = false

    var body: some View {
        VStack {
            // WebView pour afficher l'interface de l'IA
            WebView(resultText: $resultText)
                .cornerRadius(10)
                .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                // Bouton pour envoyer l'image et le résultat au backend
                Button("Sauvegarder le résultat") {
                    sendHistoryToBackend(image: selectedImage, result: resultText)
                }
                .padding()
            }

            // Bouton pour ouvrir le sélecteur d'image
            Button("Choisir une image") {
                showImagePicker = true
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .padding()
    }

    // Fonction pour convertir l'image en base64
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }

    // Fonction pour envoyer l'image et le résultat au backend
    func sendHistoryToBackend(image: UIImage, result: String) {
        guard let base64Image = convertImageToBase64(image: image) else {
            print("Erreur lors de la conversion de l'image en base64")
            return
        }

        // Récupérer le token d'accès depuis UserDefaults
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            return
        }
        

        // Créer un objet JSON avec l'image et la description
        let woundHistory: [String: Any] = [
            "image": base64Image,
            "description": result,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]

        // Effectuer la requête POST à votre backend
        guard let url = URL(string: "http://172.18.19.1:3001/history") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")  // Ajouter le token à l'en-tête

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: woundHistory, options: .prettyPrinted)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur lors de l'envoi de l'historique : \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Réponse du serveur : \(responseString)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Erreur lors de la préparation des données : \(error.localizedDescription)")
        }
    }
}

// WebView pour afficher l'interface Gradio
struct WebView: UIViewRepresentable {
    @Binding var resultText: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "AndroidBridge")

        // Charger l'application Gradio
        if let url = URL(string: "https://mirai310-wound-identifier-2.hf.space") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // Réception des messages depuis le JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "AndroidBridge", let result = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.resultText = "Résultat : \(result)"
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = """
            (function() {
                const observer = new MutationObserver(() => {
                    const resultElement = document.querySelector('.output-class.svelte-1pq4gst');
                    if (resultElement) {
                        const result = resultElement.innerText || resultElement.textContent;
                        window.webkit.messageHandlers.AndroidBridge.postMessage(result);
                    }
                });
                observer.observe(document.body, { childList: true, subtree: true });
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

// ImagePicker pour choisir une image depuis la galerie
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
*/

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var resultText: String = "Résultat : Aucun"

    var body: some View {
        VStack {
            // WebView pour afficher l'interface de l'IA
            WebView(resultText: $resultText, selectedImage: $selectedImage)
                .cornerRadius(10)
                .padding()

            // Vérifier si une image a été sélectionnée
            if let selectedImage = selectedImage {
                // Afficher l'image si elle a été sélectionnée
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                // Bouton pour sauvegarder le résultat
                Button("Sauvegarder le résultat") {
                    sendHistoryToBackend(image: selectedImage, result: resultText)
                }
                .padding()
                .frame(maxWidth: .infinity) // Assurez-vous que le bouton occupe toute la largeur possible
                .background(Color.blue) // Ajoutez un fond pour rendre le bouton plus visible
                .foregroundColor(.white) // Couleur du texte du bouton
                .cornerRadius(10) // Arrondir les coins du bouton
            } else {
                Text("Aucune image sélectionnée")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    // Fonction pour convertir l'image en base64
    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }

    // Fonction pour envoyer l'image et le résultat au backend
    func sendHistoryToBackend(image: UIImage, result: String) {
        guard let base64Image = convertImageToBase64(image: image) else {
            print("Erreur lors de la conversion de l'image en base64")
            return
        }

        // Récupérer le token d'accès depuis UserDefaults
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            return
        }

        // Créer un objet JSON avec l'image et la description
        let woundHistory: [String: Any] = [
            "image": base64Image,
            "description": result,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]

        // Effectuer la requête POST à votre backend
        guard let url = URL(string: "http://172.18.19.1:3001/history") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")  // Ajouter le token à l'en-tête

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: woundHistory, options: .prettyPrinted)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur lors de l'envoi de l'historique : \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Réponse du serveur : \(responseString)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Erreur lors de la préparation des données : \(error.localizedDescription)")
        }
    }
}

// WebView pour afficher l'interface Gradio et récupérer l'image téléchargée
struct WebView: UIViewRepresentable {
    @Binding var resultText: String
    @Binding var selectedImage: UIImage?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "AndroidBridge")
        
        // Charger l'application Gradio
        if let url = URL(string: "https://mirai310-wound-identifier-2.hf.space") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
     var parent: WebView
     
     init(_ parent: WebView) {
     self.parent = parent
     }
     
     // Réception des messages depuis le JavaScript
     func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
     // Vérifier que le message reçu est bien l'image en base64
     if let base64Image = message.body as? String {
     // Convertir le base64 en UIImage
     if let imageData = Data(base64Encoded: base64Image), let image = UIImage(data: imageData) {
     DispatchQueue.main.async {
     self.parent.selectedImage = image
     }
     }
     }
     }
     
     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
     // Injecter le script JavaScript pour détecter le téléchargement de l'image
     let script = """
     (function() {
     const inputElement = document.querySelector('input[type="file"]');
     if (inputElement) {
     inputElement.addEventListener('change', function(event) {
     const file = event.target.files[0];
     if (file && file.type.startsWith('image/')) {
     const reader = new FileReader();
     reader.onload = function(e) {
     window.webkit.messageHandlers.AndroidBridge.postMessage(e.target.result);
     };
     reader.readAsDataURL(file); // Convertir l'image en base64
     }
     });
     }
     })();
     """
     webView.evaluateJavaScript(script, completionHandler: nil)
     }
     }
     }
   
