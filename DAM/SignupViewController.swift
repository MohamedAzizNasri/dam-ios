//
//  SignupViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var PasswordSU: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var mail: UITextField!
    
    @IBAction func signUp(_ sender: Any) {
        // Récupérer les valeurs des champs de texte
        let nameS = name.text
        let emailS = mail.text
        let PasswordSUS = PasswordSU.text
        let phoneNumberS = phoneNumber.text

        // Vérifier si tous les champs sont remplis
       if nameS?.isEmpty == true || emailS?.isEmpty == true || PasswordSUS?.isEmpty == true || phoneNumberS?.isEmpty == true {
            // Show an alert if any field is empty
            showAlert(title: "Missing informations .", message: "Please fill all the fields.")
            
        }else {
            showAlert(title: "Congratulations !", message: "Your account was created.")
        }

        // Assuming the account creation process happens here and is successful

        // Préparer les paramètres pour la requête d'inscription
        let parameters: [String: Any] = [
            "username": nameS!,
            "email": emailS!,
            "password": PasswordSUS!,
            "phone": phoneNumberS!
        ]

        // Envoyer la requête d'inscription
        sendSignupRequest(parameters: parameters)

        // Si tout est bon, vous pouvez continuer avec la navigation vers la page suivante
        // Navigation vers la page suivante uniquement si tous les champs sont remplis
       // self.performSegue(withIdentifier: "signUp", sender: self)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {

            addIconToTextField(name, iconName: "person.fill")
            addIconToTextField(mail, iconName: "envelope.fill")
            addIconToTextField(PasswordSU, iconName: "lock.fill")
        addIconToTextField(phoneNumber, iconName: "phone.fill")
            
        
        // Créer le bouton pour basculer la visibilité du mot de passe
        let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal) // Icône œil barré
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Ajouter le bouton en tant que vue de droite du UITextField
        PasswordSU.rightView = toggleButton
        PasswordSU.rightViewMode = .always
        PasswordSU.isSecureTextEntry = true // Masquer le mot de passe par défaut
            super.viewDidLoad()

            // Do any additional setup after loading the view.
        }
    
    @objc private func togglePasswordVisibility() {
        PasswordSU.isSecureTextEntry.toggle() // Bascule entre masqué et visible

        // Mettre à jour l’icône du bouton en fonction de l’état
        if let button = PasswordSU.rightView as? UIButton {
            let buttonImageName = PasswordSU.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: buttonImageName), for: .normal)
        }
    }
       
        func addIconToTextField(_ textField: UITextField, iconName: String) {
            if let icon = UIImage(systemName: iconName) {
                let iconView = UIImageView(image: icon)
                iconView.contentMode = .scaleAspectFit
                iconView.tintColor = UIColor.darkGray
                iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                
                textField.leftView = iconView
                textField.leftViewMode = .always
            }
        }
       
       
        // Sends the signup request to the server
        private func sendSignupRequest(parameters: [String: Any]) {
            guard let url = URL(string: "http://172.18.8.47:3000/auth/signup") else { return }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    guard let data = data else {
                        print("No data received")
                        return
                    }

                    self.handleResponse(data: data)
                }

                // Start the request task
                task.resume()

            } catch {
                print("Error serializing JSON: \(error.localizedDescription)")
            }
        }

        // Handles the response from the server
        private func handleResponse(data: Data) {
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")

                // Attempt to parse the response as JSON
                if let jsonData = responseString.data(using: .utf8) {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            // Check the status code
                            if let statusCode = jsonResponse["statusCode"] as? Int {
                                // If status code is 200, perform the segue to "home"
                                print(statusCode)
                                if statusCode == 200 {
                                    print("signup is done sucessfully")
                                    DispatchQueue.main.async {
                                        // Perform the segue to "home"
                                        self.performSegue(withIdentifier: "home", sender: nil)
                                    }
                                } else if statusCode == 400  || statusCode ==   401  {
                                    // Handle the specific action for status code 400 (e.g., Email already in use)
                                   
                                }
                            }
                        }
                    } catch {
                        print("Failed to parse JSON: \(error.localizedDescription)")
                    }
                }
            }
        }


    }

