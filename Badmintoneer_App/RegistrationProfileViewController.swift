//
//  RegistrationProfileViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

import UIKit
import KeychainAccess

class RegistrationProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBAction func nextBtnClicked(_ sender: Any) {
        
        //save details to keychain
        let keychain = Keychain(service: ConstantsList.Application.bundleID)
        keychain[ConstantsList.Keychains.nameKeychain] = nameTextField.text
        keychain[ConstantsList.Keychains.emailKeychain] = usernameTextField.text
        keychain[ConstantsList.Keychains.passwordKeychain] = passwordTextField.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        errorLabel.alpha = 0
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //set keyboard to be visible for text field
        nameTextField.becomeFirstResponder()
    }
    
    func validateFields() -> String? {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
//            displayMessage(title: "Error", message: "Please fill in all text fields")
            return "Please fill in all text fields"
        }
        
        let legitEmail = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !isEmailValid(legitEmail) {
            //displayMessage(title: "Error", message: "Username not in correct email format")
            return "Email not in correct format"
        }
        
        let legitPassword = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !isPasswordValid(legitPassword) {
            //displayMessage(title: "Error", message: "Password needs to contain minimally eight charactors and at least one special character")
            return "Password needs to contain minimally eight charactors and at least one special character"
        }
        
        return nil
    }
    
    func showErrorMsg(_ message : String, fadeOutDelay : Double){
        errorLabel.text = message
        errorLabel.alpha = 1
        UIView.animate(withDuration: 1.5, delay: fadeOutDelay, animations: {
            self.errorLabel.alpha = 0
        })
        
        errorLabel.shake()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if (segue.identifier == "RegProfileToImageSegue"){
//            let destination = segue.destination as! RegistrationBioViewController
//
//        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "RegProfileToImageSegue"){
//            let destination = segue.destination as! RegistrationBioViewController

            let error = validateFields()
            
            if error != nil {
                showErrorMsg(error ?? "An error ocurrred. Please reenter fields.", fadeOutDelay: 7)
                return false
            }
        }
        return true
    }
}


