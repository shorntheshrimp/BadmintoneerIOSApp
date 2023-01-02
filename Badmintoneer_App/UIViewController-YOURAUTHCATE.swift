//
//  UIViewController-YOURAUTHCATE.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

// MARK: - Credits
// Generic parameters - https://stackoverflow.com/questions/48594536/how-to-pass-a-type-of-uiviewcontroller-to-a-function-and-type-cast-a-variable-in
// Animating UIViews position (for error label) - https://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift/38790163

import Foundation
import UIKit
import Firebase
import KeychainAccess

extension UIViewController {
    
    func displayMessage(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    self.present(alertController, animated: true, completion: nil)
    }
    
    func isPasswordValid(_ password : String) -> Bool {
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&`~^-_+=]).{8,}$")

        return passwordCheck.evaluate(with: password)
    }
    
    func isEmailValid(_ email : String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isInt(chkString: String) -> Bool {
        return Int(chkString) != nil
    }
    
    //Because retrieving data is asynchronous, any subsequent code/functions need to be passed in here as there is no control when the completion ends, so the order is not mixed up.
    //The return parameter is set as an optional function so that it can be used without any follow up code
    func getUserData(completionHander: (() -> Void)? ){
        
        let defaults = UserDefaults.standard
        
        let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let uid = user?.uid{

                guard let email = user?.email else {
                    print ("Email not found")
                    return
                }
                
                defaults.set(email, forKey: ConstantsList.Defaults.emailDef)
                print("New Email: \(defaults.string(forKey: ConstantsList.Defaults.emailDef) ?? "no defaults for emailDef")")
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(uid)

                docRef.getDocument { ( document,error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print ("Document data: \(dataDescription)")

                        //Set UserDefaults from firestore Start
                        let nameKey = ConstantsList.FirestoreKeys.nameKey
                        let bioKey = ConstantsList.FirestoreKeys.bioKey
                        let profilePicKey = ConstantsList.FirestoreKeys.profilePicKey
                        let setsKey = ConstantsList.FirestoreKeys.setsKey
                        let swingKey = ConstantsList.FirestoreKeys.swingsKey
                        let delayKey = ConstantsList.FirestoreKeys.delayKey
                        let recoveryKey = ConstantsList.FirestoreKeys.recoveryKey
                        let setsEarnedKey = ConstantsList.FirestoreKeys.setsEarnedKey
                        let swingsEarnedKey = ConstantsList.FirestoreKeys.swingsEarnedKey
                        
                        let nameDef = ConstantsList.Defaults.nameDef
                        let bioDef = ConstantsList.Defaults.bioDef
                        let profilePicDef = ConstantsList.Defaults.profilePicDef
                        let setsDef = ConstantsList.Defaults.setsDef
                        let swingsDef = ConstantsList.Defaults.swingsDef
                        let delayDef = ConstantsList.Defaults.delayDef
                        let recoveryDef = ConstantsList.Defaults.recoveryDef
                        let setsEarnedDef = ConstantsList.Defaults.setsEarnedDef
                        let swingsEarnedDef = ConstantsList.Defaults.swingsEarnedDef
                        
                        // set user account defaults -----
                        guard let nameData = document.get(nameKey)
                        else {
                            print("name in firebase document could not be loaded")
                            return
                        }
                        print("Cloud firestore document: Name: \(nameData)")
                        defaults.set(nameData, forKey: nameDef)
                        print("Changed UserDefaults name: \(defaults.string(forKey: nameDef) ?? "no defaults for nameDef")")
                        
                        guard let bioData = document.get(bioKey)
                        else {
                            print("bio in firebase document could not be loaded")
                            return
                        }
                        print("Cloud firestore document: bio: \(bioData)")
                        defaults.set(bioData, forKey: bioDef)
                        
                        guard let imageData = document.get(profilePicKey)
                        else {
                            print("image in firebase document could not be loaded")
                            return
                        }
                        defaults.set(imageData, forKey: profilePicDef)
                        // -----
                        
                        // set Training Simulation Preferences -----
                        let dSets = ConstantsList.DefaultValues.setsVal
                        let dSwings = ConstantsList.DefaultValues.swingsVal
                        let dDelay = ConstantsList.DefaultValues.delayVal
                        let dRecovery = ConstantsList.DefaultValues.recoveryVal
                        
                        guard let setsData = document.get(setsKey)
                        else {
                            print("training pref: sets in firebase document could not be loaded")
                            defaults.set(dSets, forKey: setsDef)
                            return
                        }
                        defaults.set(setsData, forKey: setsDef)
                        
                        guard let swingsData = document.get(swingKey)
                        else {
                            print("training pref: swings in firebase document could not be loaded")
                            defaults.set(dSwings, forKey: swingsDef)
                            return
                        }
                        defaults.set(swingsData, forKey: swingsDef)
                        
                        guard let delayData = document.get(delayKey)
                        else {
                            print("training pref: delay in firebase document could not be loaded")
                            defaults.set(dDelay, forKey: delayDef)
                            return
                        }
                        defaults.set(delayData, forKey: delayDef)
                        
                        guard let recoveryData = document.get(recoveryKey)
                        else {
                            print("training pref: recovery in firebase document could not be loaded")
                            defaults.set(dRecovery, forKey: recoveryDef)
                            return
                        }
                        defaults.set(recoveryData, forKey: recoveryDef)
                        
                        guard let setsEarnedData = document.get(setsEarnedKey)
                        else {
                            print("training pref: Sets earned in firebase document could not be loaded")
                            return
                        }
                        defaults.set(setsEarnedData, forKey: setsEarnedDef)
                        
                        guard let swingsEarnedData = document.get(swingsEarnedKey)
                        else {
                            print("training pref: Swings earned in firebase document could not be loaded")
                            return
                        }
                        defaults.set(swingsEarnedData, forKey: swingsEarnedDef)
                        // -----
                        //Set UserDefaults from firestore End
                        
                        //loads any code that needs to be implemented in the class that it was called
                        if completionHander != nil {
                            completionHander!()
                        }

                    
                    } else {
                        print("Document does not exist")
                    }
                }
                
            } else {
                print ("User not found")
                return
            }
        }
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    func signOutUser(){
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch {
            print("cannot sign out")
        }
    }
    
    func setDefaultsUsername(username : String?){
        let defaults = UserDefaults.standard
        
        defaults.setValue(username, forKey: ConstantsList.Defaults.nameDef)
    }
    
    
    func clearUserDefaults(){
        
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: ConstantsList.Defaults.emailDef)
        defaults.removeObject(forKey: ConstantsList.Defaults.nameDef)
        defaults.removeObject(forKey: ConstantsList.Defaults.bioDef)
        defaults.removeObject(forKey: ConstantsList.Defaults.profilePicDef)
        
        defaults.removeObject(forKey: ConstantsList.TempValues.bioTemp)
        
//        defaults.removePersistentDomain(forName: ConstantsList.Application.bundleID)
    }
    
    func clearKeyChains(){
        
        let keychain = Keychain(service: ConstantsList.Application.bundleID)
        
        do {
            try keychain.removeAll()
        } catch {
            print("Nothing in keychain to remove")
        }
    }
    
    func transitionToMenu<V: UIViewController>(viewCon: V.Type, viewID: String){
        
        let startViewController = storyboard?.instantiateViewController(identifier: viewID) as? V
        
        view.window?.rootViewController = startViewController
        view.window?.makeKeyAndVisible()
    }
    
//    func getUserInfo(onSuccess : @escaping () -> Void, onError : @escaping ( _ error: Error?) -> Void) {
//        let ref = Database.database().reference()
//        let defaults = UserDefaults.standard
//
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("User not found")
//            return
//        }
//
//        ref.child("users").child(uid).observe(.value, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String : Any] {
//                let email = dictionary["email"] as! String
//                let name = dictionary["name"] as! String
//
//                defaults.set(email, forKey: ConstantsList.Defaults.emailDef)
//                defaults.set(name, forKey: ConstantsList.Defaults.nameDef)
//            }
//
//        }) { (error) in
//            onError(error)
//        }
//    }
}

// MARK: - Extensions

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
