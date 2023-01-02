//
//  StartScreenViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

// MARK: - Credits
// Login features - https://www.youtube.com/watch?v=1HN7usMROt8&list=RDCMUC2D6eRvCeMtcF5OGHf1-trw&start_radio=1&rv=1HN7usMROt8&t=5597

import UIKit
import Firebase
import FirebaseAuth

class StartScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: ConstantsList.Defaults.isSignedIn) == true {
            getUserData{ self.transitionToLoginPreview() }
        }
        
        
//        if FirebaseAuth.Auth.auth().currentUser != nil {
//            transitionToLoginPreview()
//        }
        
        
        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "StartToLoginSegue"){
//            let destination = segue.destination as! LoginViewController
        }
        if (segue.identifier == "StartToRegistrationSegue"){
//            let destination = segue.destination as! RegistrationProfileViewController
        }
    }
    
    func transitionToLoginPreview(){
        
        let loginPreviewViewController = storyboard?.instantiateViewController(identifier: ConstantsList.Storyboard.loginPVC) as? LoginPreviewViewController
        
        view.window?.rootViewController = loginPreviewViewController
        view.window?.makeKeyAndVisible()
    }

}
