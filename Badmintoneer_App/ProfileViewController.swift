//
//  ProfileViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 6/5/21.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController {

    var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var achievementSeniorityIV: UIImageView!
    @IBOutlet weak var achievementSetsIV: UIImageView!
    
    @IBOutlet weak var achievementSeniorityLabel: UILabel!
    @IBOutlet weak var achievementSetsLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UITextView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePicimageView: UIImageView!
    @IBOutlet weak var editDescriptionBtn: UIButton!
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            print("signed out")
        }
        catch {
            print("cannot sign out")
        }
        
        let userDef = UserDefaults.standard
        
        clearUserDefaults()
        clearKeyChains()
        userDef.set(false , forKey: ConstantsList.Defaults.isSignedIn)
//        userDef.removePersistentDomain(forName: ConstantsList.Application.bundleID)
        
        transitionToMenu(viewCon: StartScreenViewController.self, viewID: ConstantsList.Storyboard.startVC)
    }
    //edit button function--------------------------
    @IBAction func editBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Edit Description", message: "Add something interesting about yourself!", preferredStyle: .alert)
        
        //textfield
        alert.addTextField{ (edit) in
            edit.placeholder = "Press to enter your new description!"
        }
        
        //action buttons
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            self.indicator.startAnimating()
            
            let bioTemp = alert.textFields![0].text!
            let bioKey = ConstantsList.FirestoreKeys.bioKey
            
            let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let uid = user?.uid{
                    let db = Firestore.firestore()
                    db.collection("users").document(uid).setData([
                        bioKey : bioTemp,
                    ], merge: true)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.indicator.stopAnimating()
                            self.displayMessage(title: "Error", message: "Could not save changes to database")
                            return
                        }
                            
                        DispatchQueue.main.async {
                                 
                            let userDef = UserDefaults.standard
                                
                            userDef.set(bioTemp, forKey: ConstantsList.Defaults.bioDef)
                                
                            let defaultBio = userDef.string(forKey: ConstantsList.Defaults.bioDef)

                            self.bioLabel.text = defaultBio
                                    
                            self.indicator.stopAnimating()
                                
                            print("Document successfully written!")
                        
                            self.indicator.stopAnimating()
                        }
                    }
                }
            }
            Auth.auth().removeStateDidChangeListener(listener)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            
        })
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editDescriptionBtn.layer.cornerRadius = 10
        
        //set achievement stats
        if let aSenIV = UIImage(systemName: "mustache.fill"){
        achievementSeniorityIV.image = aSenIV
        }
        if let aSetsIV = UIImage(systemName: "rosette"){
        achievementSetsIV.image = aSetsIV
        }
        
        let startDate = (Auth.auth().currentUser?.metadata.creationDate)!
        let currentDate = (Auth.auth().currentUser?.metadata.lastSignInDate)!

        let daysJoined = Calendar.current.dateComponents([.day], from: startDate, to: currentDate)
        print("Number of days joined: \(daysJoined.day!)")

        achievementSeniorityIV.image?.withRenderingMode(.alwaysTemplate)
        achievementSeniorityLabel.numberOfLines = 2
        achievementSeniorityLabel.lineBreakMode = NSLineBreakMode.byWordWrapping

        if daysJoined.day! < 30{
            formatImageView(img: achievementSeniorityIV, bordercolor: UIColor.brown.cgColor)
            achievementSeniorityIV.tintColor = .brown
            achievementSeniorityLabel.text = "Newbie"
        } else if daysJoined.day! >= 30, daysJoined.day! < 100{
            formatImageView(img: achievementSeniorityIV, bordercolor: UIColor.orange.cgColor)
            achievementSeniorityIV.tintColor = .orange
            achievementSeniorityLabel.text = "Veteran"
        } else if daysJoined.day! >= 100{
            formatImageView(img: achievementSeniorityIV, bordercolor: UIColor.red.cgColor)
            achievementSeniorityIV.tintColor = .red
            achievementSeniorityLabel.text = "Chief"
        }

        achievementSetsIV.image?.withRenderingMode(.alwaysTemplate)
        achievementSetsLabel.numberOfLines = 2
        achievementSetsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        getUserData(completionHander: {
            let setsEarned = UserDefaults.standard.string(forKey: ConstantsList.Defaults.setsEarnedDef)

            if Int(setsEarned!)! < 20{
                self.formatImageView(img: self.achievementSetsIV, bordercolor: UIColor.brown.cgColor)
                self.achievementSetsIV.tintColor = .brown
                self.achievementSetsLabel.text = "Rookie"
            } else if Int(setsEarned!)! >= 20, Int(setsEarned!)! < 50{
                self.formatImageView(img: self.achievementSetsIV, bordercolor: UIColor.orange.cgColor)
                self.achievementSetsIV.tintColor = .orange
                self.achievementSetsLabel.text = "Skilled"
            } else if Int(setsEarned!)! >= 50{
                self.formatImageView(img: self.achievementSetsIV, bordercolor: UIColor.red.cgColor)
                self.achievementSetsIV.tintColor = .red
                self.achievementSetsLabel.text = "Ace"
            }
        })


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
        
        //format profile pic
        formatImageView(img: profilePicimageView, bordercolor: UIColor.gray.cgColor)
        
        //load profile pic and username
        let uDefaults = UserDefaults.standard

        if let picData = uDefaults.data(forKey: ConstantsList.Defaults.profilePicDef) {
            print("profile pic is \(picData)")
            profilePicimageView.image = UIImage(data: (picData as NSData) as Data)
        } else {
            print("no profile pic loaded...")
        }
        
        if let defaultName = uDefaults.string(forKey: ConstantsList.Defaults.nameDef){
            profileNameLabel.text = defaultName
        }
        
        if let defaultBio = uDefaults.string(forKey: ConstantsList.Defaults.bioDef){
            bioLabel.text = defaultBio
        }
    }
    
    func formatImageView(img: UIImageView, bordercolor: CGColor){
        img.tintColor = .gray
        img.contentMode = .scaleAspectFit
        img.layer.borderWidth = 2.0
        img.layer.masksToBounds = true
        img.layer.borderColor = bordercolor
        img.layer.cornerRadius = img.frame.size.width / 2
        img.clipsToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    func transitionToStart(){
//
//        let startViewController = storyboard?.instantiateViewController(identifier: ConstantsList.Storyboard.startVC) as? StartScreenViewController
//
//        view.window?.rootViewController = startViewController
//        view.window?.makeKeyAndVisible()
//    }

}
