//
//  LoginPreviewViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 29/4/21.
//

import UIKit

class LoginPreviewViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    var name : String?
    var picData : Any?
    var timerVar = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePhotoImageView.tintColor = .gray
        profilePhotoImageView.contentMode = .scaleAspectFit
        profilePhotoImageView.layer.borderWidth = 2.0
        profilePhotoImageView.layer.masksToBounds = true
        profilePhotoImageView.layer.borderColor = UIColor.gray.cgColor
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.width / 2
        profilePhotoImageView.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        let defaults = UserDefaults.standard

        print (defaults.string(forKey: ConstantsList.Defaults.nameDef) ?? "ProfilePreview: noname")
        name = defaults.string(forKey: ConstantsList.Defaults.nameDef)

        if !(name?.isEmpty ?? true){
            print("Inside LoginPreview, name: \(name ?? "username not retrieved")")
            usernameLabel.text = name
        } else {
            print("no profile name loaded...")
        }
        
        
        picData = defaults.data(forKey: ConstantsList.Defaults.profilePicDef)
        
        if picData != nil {
            print("profile pic is \(picData!)")
            profilePhotoImageView.image = UIImage(data: (picData! as! NSData) as Data)
        } else {
            print("no profile pic loaded...")
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LoginPreviewViewController.increTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let defaults = UserDefaults.standard
//
//        name = defaults.string(forKey: ConstantsList.Defaults.nameDef)
//
//        if ((name?.isEmpty) != nil){
//            print("Inside LoginPreview, name: \(name ?? "username not retrieved")")
//            usernameLabel.text = name
//        }
    }
    
    @objc func increTimer(){
        timerVar += 1
        
        print(timerVar)
        if timerVar == 3 {
            timer.invalidate()
            transitionToMenu(viewCon: MainTabBarViewController.self, viewID: ConstantsList.Storyboard.mainTBVC)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
