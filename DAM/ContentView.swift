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
        guard let url = URL(string: "http://172.18.2.149:3000/history") else { return }
        
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
}

