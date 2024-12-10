/*
import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var resultText: String = "Résultat : Aucun"
    @State private var showImagePicker = false
    @State private var isLoading = false

    var body: some View {
        VStack {
      
            // WebView pour afficher et interagir avec l'IA
            WebView(resultText: $resultText)
              
                .cornerRadius(10)
        }
        .padding()
    }
}

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
            // Injecter le script JavaScript pour observer les résultats
            let script = """
            (function() {
                const observer = new MutationObserver(() => {
                    const resultElement = document.querySelector('.output-class.svelte-1pq4gst');
                    if (resultElement) {
                        const results = resultElement.innerText || resultElement.textContent;
                        window.webkit.messageHandlers.AndroidBridge.postMessage(results);
                    }
                });
                observer.observe(document.body, { childList: true, subtree: true });
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

*/
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
                Button("Envoyer l'image et le résultat") {
                    sendHistoryToBackend(image: selectedImage, result: resultText)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerViewController(selectedImage: $selectedImage)
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

        let woundHistory = [
            "image": base64Image,
            "description": result, // Utilisation du texte résultant de l'IA
        ]

        // Effectuer la requête POST à votre backend
        guard let url = URL(string: "http://172.18.8.47:3001/history") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: woundHistory, options: .prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur lors de l'envoi de l'historique : \(error.localizedDescription)")
                    return
                }
                // Traitez la réponse du serveur ici si nécessaire (optionnel)
            }
            task.resume()
        } catch {
            print("Erreur lors de la préparation des données : \(error.localizedDescription)")
        }
    }
}

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
            // Injecter le script JavaScript pour observer les résultats
            let script = """
            (function() {
                const observer = new MutationObserver(() => {
                    const resultElement = document.querySelector('.output-class.svelte-1pq4gst');
                    if (resultElement) {
                        const results = resultElement.innerText || resultElement.textContent;
                        window.webkit.messageHandlers.AndroidBridge.postMessage(results);
                    }
                });
                observer.observe(document.body, { childList: true, subtree: true });
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}*/
import SwiftUI
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
        guard let url = URL(string: "http://192.168.1.161:3001/history") else { return }

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


/*import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var resultText: String = "Résultat : Aucun"
    @State private var isLoading = false

    var body: some View {
        VStack {
            WebView(resultText: $resultText, selectedImage: $selectedImage)
                .cornerRadius(10)
                .padding()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                Text(resultText)
                    .padding()

                Button("Sauvegarder le résultat") {
                    sendHistoryToBackend(image: selectedImage, result: resultText)
                }
                .padding()
            } else {
                Text("Aucune image sélectionnée")
                    .padding()
            }
        }
        .padding()
    }

    func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }

    func sendHistoryToBackend(image: UIImage, result: String) {
        guard let base64Image = convertImageToBase64(image: image) else {
            print("Erreur lors de la conversion de l'image en base64")
            return
        }

        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Aucun token d'accès trouvé dans UserDefaults.")
            return
        }

        let woundHistory: [String: Any] = [
            "image": base64Image,
            "description": result,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]

        guard let url = URL(string: "http://172.18.8.47:3001/history") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

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

struct WebView: UIViewRepresentable {
    @Binding var resultText: String
    @Binding var selectedImage: UIImage?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "ImageBridge")

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

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "ImageBridge", let base64String = message.body as? String {
                self.fetchImage(from: base64String)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let script = """
            (function() {
                const imgElement = document.querySelector('img');  // Get the first <img> element
                if (imgElement) {
                    const imageUrl = imgElement.src;
                    console.log('Image URL:', imageUrl);  // Check if the image URL is correct
                    fetch(imageUrl)
                        .then(response => response.blob())
                        .then(blob => {
                            const reader = new FileReader();
                            reader.onloadend = function() {
                                const base64String = reader.result.split(',')[1];
                                console.log('Base64 String:', base64String);  // Check the base64 string
                                window.webkit.messageHandlers.ImageBridge.postMessage(base64String);
                            };
                            reader.readAsDataURL(blob);
                        })
                        .catch(err => console.log('Error fetching image:', err));
                }
            })();
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }

        func fetchImage(from base64String: String) {
            if let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.parent.selectedImage = image
                }
            }
        }
    }
}
*/
