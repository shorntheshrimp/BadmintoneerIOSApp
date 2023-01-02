//
//  RegistrationBioViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

import UIKit
import FirebaseAuth
import Firebase
import KeychainAccess

class RegistrationBioViewController: UIViewController {

//    var name : String?
//    var username : String?
//    var password : String?
//    var bio : String?
    
    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBAction func registerBtnClicked(_ sender: Any) {
        
        indicator.startAnimating()
        
        let keychain = Keychain(service: ConstantsList.Application.bundleID)
        let uDef = UserDefaults.standard
        
        let name = keychain[ConstantsList.Keychains.nameKeychain]
        let username = keychain[ConstantsList.Keychains.emailKeychain]
        let password = keychain[ConstantsList.Keychains.passwordKeychain]
        let profilepic = uDef.data(forKey: ConstantsList.Defaults.profilePicDef)
        
        uDef.set(bioTextView.text, forKey: ConstantsList.Defaults.bioDef)
        let bio = uDef.string(forKey: ConstantsList.Defaults.bioDef)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: username ?? "", password: password ?? "", completion: { [weak self]result, error in
            
            guard let strongSelf = self
            else {
                return
            }
            
            guard error == nil
            else {
                //show account creation
                print(error ?? "")
                print("account cannot be created")
                strongSelf.showErrorMsg("account cannot be created...")
                strongSelf.indicator.stopAnimating()
                return
            }
            
            print("account with name \(name ?? "empty name") is created")
            let db = Firestore.firestore()
                
            //if auto generate document name use this
//            db.collection("users").addDocument(data: ["name" : strongself.name!, "bio" : strongself.bio!, "uid" : result!.user.uid])
            
            let nameKey = ConstantsList.FirestoreKeys.nameKey
            let bioKey = ConstantsList.FirestoreKeys.bioKey
            let profilePicKey = ConstantsList.FirestoreKeys.profilePicKey
            
            let dSets = ConstantsList.DefaultValues.setsVal
            let dSwings = ConstantsList.DefaultValues.swingsVal
            let dDelay = ConstantsList.DefaultValues.delayVal
            let dRecovery = ConstantsList.DefaultValues.recoveryVal
            
            let setsKey = ConstantsList.FirestoreKeys.setsKey
            let swingsKey = ConstantsList.FirestoreKeys.swingsKey
            let delayKey = ConstantsList.FirestoreKeys.delayKey
            let recoveryKey = ConstantsList.FirestoreKeys.recoveryKey
            
            let dSetsEarned = ConstantsList.Defaults.setsEarnedDef
            let dSwingsEarned = ConstantsList.Defaults.swingsEarnedDef
            
            let setsEarnedKey = ConstantsList.FirestoreKeys.setsEarnedKey
            let swingsEarnedKey = ConstantsList.FirestoreKeys.swingsEarnedKey
            
            db.collection("users").document(result!.user.uid).setData([
                nameKey : name ?? "",
                bioKey : bio ?? "",
                profilePicKey : profilepic as Any,
                setsKey : dSets,
                swingsKey : dSwings,
                delayKey : dDelay,
                recoveryKey : dRecovery,
                setsEarnedKey : "0",
                swingsEarnedKey : "0"
            ]) { (error) in
                    
                if error != nil {
                    print("error: \(String(describing: error))")

                    strongSelf.showErrorMsg("user data not saved")
                    
                    strongSelf.indicator.stopAnimating()
                    return
                } else {
                    let setsDef = ConstantsList.Defaults.setsDef
                    let swingsDef = ConstantsList.Defaults.swingsDef
                    let delayDef = ConstantsList.Defaults.delayDef
                    let recoveryDef = ConstantsList.Defaults.recoveryDef
                    
                    uDef.set(dSets, forKey: setsDef)
                    uDef.set(dSwings, forKey: swingsDef)
                    uDef.set(dDelay, forKey: delayDef)
                    uDef.set(dRecovery, forKey: recoveryDef)
                    
                    uDef.set("0", forKey: dSetsEarned)
                    uDef.set("0", forKey: dSwingsEarned)
                }
                    
            }
        
            DispatchQueue.main.async {
                
                uDef.set(true , forKey: ConstantsList.Defaults.isSignedIn)
                
                strongSelf.getUserData{
                    strongSelf.transitionToMenu(viewCon: LoginPreviewViewController.self, viewID: ConstantsList.Storyboard.loginPVC)
                    
                    strongSelf.indicator.stopAnimating()
                }
                
            }
            
        })
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        errorLabel.alpha = 0
        self.bioTextView.layer.borderColor = UIColor.gray.cgColor
        self.bioTextView.layer.borderWidth = 1
//        print(name!)
//        print(username!)
//        print(password!)
        
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
        
        //set keyboard to be visible for text view
        bioTextView.becomeFirstResponder()
        
//        print(name ?? "name not retrieved")
//        print(username ?? "name not retrieved")
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
