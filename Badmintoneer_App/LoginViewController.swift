//
//  LoginViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 27/4/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    //go to initial registration profile VC
    @IBAction func createNewAccPressed(_ sender: Any) {
        let newProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: ConstantsList.Storyboard.createNewAccVC) as! RegistrationProfileViewController
        self.navigationController?.pushViewController(newProfileViewController, animated: true)
    }
    @IBOutlet weak var forgotPasswordButton: UIButton!
    //sends an email to reset password to email registered
    @IBAction func forgotPasswordClicked(_ sender: Any) {
//        displayMessage(title: "Mistakes were made", message: "Let this be a lesson learnt, write it down next time")
        
        guard let email = usernameTextField.text
        else {
            return
        }
        
        if email.isEmpty{
            showErrorMsg("Please input an email")
        }
        
        let alert = UIAlertController(title: "Reset Password", message: "Would you like to send a password reset request to \(email)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if let error = error{
    
                    self.showErrorMsg("Error: \(String(describing: error.localizedDescription))")
                            
                } else {
                            
                    self.displayMessage(title: "Success!", message: "Reset has been sent to \(email)")
                            
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in}))
        
        present(alert, animated: true)
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        guard let user = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !user.isEmpty,
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty
        else {
            print("Fill all fields mate")
            
            showErrorMsg("Please fill in all text fields")
            
            return
        }
        
        indicator.startAnimating()
        
        //get the default auth UI object
        FirebaseAuth.Auth.auth()
            .signIn(withEmail: user, password: password, completion: { [weak self] result, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                //show account creation
                
                strongSelf.showErrorMsg("Wrong details entered")
                
                print(error as Any)
                strongSelf.indicator.stopAnimating()
                return
            }
            
            print("successful login")

            let defaults = UserDefaults.standard
            
            DispatchQueue.main.async {
                
                defaults.set(true , forKey: ConstantsList.Defaults.isSignedIn)
                
                strongSelf.getUserData {
                    strongSelf.transitionToMenu(viewCon: LoginPreviewViewController.self, viewID: ConstantsList.Storyboard.loginPVC)
                    strongSelf.indicator.stopAnimating()
                }
                
            }
            
        })
        
        
    }
    
    func showCreateNewAccount(user: String, password: String){
        let alert = UIAlertController(title: "Create New Account", message: "Would you like to create a new account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in}))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in}))
        
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        errorLabel.alpha = 0
        passwordTextField.isSecureTextEntry = true
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
        indicator.centerXAnchor.constraint(equalTo:
        view.safeAreaLayoutGuide.centerXAnchor),
        indicator.centerYAnchor.constraint(equalTo:
        view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //set keyboard to be visible for text field
        usernameTextField.becomeFirstResponder()
    }
    
    func showErrorMsg(_ message : String){
        errorLabel.text = message
        errorLabel.alpha = 1
        UIView.animate(withDuration: 1.5, delay: 5, animations: {
            self.errorLabel.alpha = 0
        })
        
        errorLabel.shake()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

