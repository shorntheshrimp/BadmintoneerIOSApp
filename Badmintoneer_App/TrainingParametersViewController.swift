//
//  TrainingParametersViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 1/6/21.
//

// MARK: - Credits
// multiline title in button - https://stackoverflow.com/questions/604632/how-do-you-add-multi-line-text-to-a-uibutton

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TrainingParametersViewController: UIViewController {

    //This VC is mainly for setting up parameters to be used in the actual training session (the following view)
    //The settings can be saved to firestore and userdefaults if required
    //However, once settings are changed, previous settings cannot be retrieved
    //Default(recommended) values are hardcoded via userdefaults for user's convenience
    
    var indicator = UIActivityIndicatorView()
    
    let setsStr = "Sets"
    let swingsStr = "Swings"
    let delayStr = "Delay"
    let recoveryStr = "Recovery"
    
    @IBOutlet weak var voiceLevelSlider: UISlider!
    @IBOutlet weak var setsBtn: UIButton!
    @IBAction func setsBtnPressed(_ sender: Any) {
        popupWindow(title: setsStr, message: "Amount of repetitive Sets in a session")
    }
    @IBOutlet weak var swingsBtn: UIButton!
    @IBAction func swingsBtnPressed(_ sender: Any) {
        popupWindow(title: swingsStr, message: "Amount of racket Swings in a Set")
    }
    @IBOutlet weak var delayBtn: UIButton!
    @IBAction func delayBtnPressed(_ sender: Any) {
        popupWindow(title: delayStr, message: "Rest time in between each Set")
    }
    @IBOutlet weak var recoveryBtn: UIButton!
    @IBAction func recoveryBtnPressed(_ sender: Any) {
        popupWindow(title: recoveryStr, message: "Rest period in between each Swing")
    }
    @IBOutlet weak var resetBtn: UIButton!
    @IBAction func resetBtnPressed(_ sender: Any) {
        
        //reset to default values
        updateUIandDefaults(sets: nil, swings: nil, delay: nil, recovery: nil)
        
    }
    @IBOutlet weak var savePrefBtn: UIButton!
    @IBAction func savePrefBtnPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Warning", message: "Do you want to overwrite previous settings?", preferredStyle: .alert)
        
        //action buttons
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            self.indicator.startAnimating()
            
            let setsKey = ConstantsList.FirestoreKeys.setsKey
            let swingKey = ConstantsList.FirestoreKeys.swingsKey
            let delayKey = ConstantsList.FirestoreKeys.delayKey
            let recoveryKey = ConstantsList.FirestoreKeys.recoveryKey
            
            let setsDef = ConstantsList.Defaults.setsDef
            let swingsDef = ConstantsList.Defaults.swingsDef
            let delayDef = ConstantsList.Defaults.delayDef
            let recoveryDef = ConstantsList.Defaults.recoveryDef
            
            let uDef = UserDefaults.standard
            let dSets = uDef.string(forKey: setsDef)
            let dSwings = uDef.string(forKey: swingsDef)
            let dDelay = uDef.string(forKey: delayDef)
            let dRecovery = uDef.string(forKey: recoveryDef)
            
            let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let uid = user?.uid{
                    let db = Firestore.firestore()
                    db.collection("users").document(uid).setData([
                        setsKey : dSets ?? "", swingKey : dSwings ?? "", delayKey : dDelay ?? "", recoveryKey : dRecovery ?? "",
                    ], merge: true)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.indicator.stopAnimating()
                        } else {

                            self.getUserData(completionHander: {
                                self.indicator.stopAnimating()
                            })
                            
                            print("Document successfully written!")
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
    @IBOutlet weak var confirmBtn: UIButton!
    @IBAction func confirmBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(voiceLevelSlider.value, forKey: ConstantsList.TempValues.volumeTemp)
    }
    @IBAction func infoBtnPressed(_ sender: Any) {
        let msgStr: String = """
            Your phone is your racket.
            To perform a successful swing, you need to generate enough swing velocity.
            *** Disclaimer: Attach your phone to your wrist with a band for safety.
            
            Follow the audio prompts and move accordingly.
            
            All commands:
            Front
            Front-left
            Front-right
            Mid-left
            Mid-right
            Back
            Back-left
            Back-right
            
            Tip 1: Move to the center of the court after each swing.
            Tip 2: Snap your wrist in the same direction of your swing.
            
            Safe training, Badmintoneer!
            """
        
        displayMessage(title: "Instructions", message: msgStr)
    }
    
    // MARK: - Overriden functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add a loading indicator view -----
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
        indicator.centerXAnchor.constraint(equalTo:
        view.safeAreaLayoutGuide.centerXAnchor),
        indicator.centerYAnchor.constraint(equalTo:
        view.safeAreaLayoutGuide.centerYAnchor)
        ])
        // -----
        
        // set ui graphic defaults -----
        setsBtn.backgroundColor = UIColor.systemBlue
        swingsBtn.backgroundColor = UIColor.systemPurple
        delayBtn.backgroundColor = UIColor.systemOrange
        recoveryBtn.backgroundColor = UIColor.systemPink
        
        let uDef = UserDefaults.standard
        let setsDef = uDef.string(forKey: ConstantsList.Defaults.setsDef)
        let swingsDef = uDef.string(forKey: ConstantsList.Defaults.swingsDef)
        let delayDef = uDef.string(forKey: ConstantsList.Defaults.delayDef)
        let recoveryDef = uDef.string(forKey: ConstantsList.Defaults.recoveryDef)
        
        let dSets = ConstantsList.DefaultValues.setsVal
        let dSwings = ConstantsList.DefaultValues.swingsVal
        let dDelay = ConstantsList.DefaultValues.delayVal
        let dRecovery = ConstantsList.DefaultValues.recoveryVal
        
        //get data from user defaults and set them to the btn titles
        formatAttributedTitleandButton(button: setsBtn, newTitle: "\(setsDef ?? dSets) sets", newSubTitle: "Total repetitive rounds in one session")
        formatAttributedTitleandButton(button: swingsBtn, newTitle: "\(swingsDef ?? dSwings) swings", newSubTitle: "Total racket swings in a set")
        formatAttributedTitleandButton(button: delayBtn, newTitle: "\(delayDef ?? dDelay) sec", newSubTitle: "The delay between Swings")
        formatAttributedTitleandButton(button: recoveryBtn, newTitle: "\(recoveryDef ?? dRecovery) sec", newSubTitle: "The recovery time in between Sets")
        
        setsBtn.layer.cornerRadius = 10
        swingsBtn.layer.cornerRadius = 10
        delayBtn.layer.cornerRadius = 10
        recoveryBtn.layer.cornerRadius = 10
        
        resetBtn.setTitle("reset to defaults", for: .normal)
        resetBtn.setTitleColor(UIColor.red, for: .normal)
        
        savePrefBtn.setTitle("Save Preferences", for: .normal)
        savePrefBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        savePrefBtn.backgroundColor = .systemBlue
        savePrefBtn.layer.cornerRadius = 10
        
        confirmBtn.setTitle("Begin Session >>>", for: .normal)
        confirmBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21)
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.backgroundColor = .systemGreen
        let maskPath = UIBezierPath(roundedRect: confirmBtn.bounds,
                    byRoundingCorners: [.topRight , .bottomRight],
                    cornerRadii: CGSize(width: 50, height: 50))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = confirmBtn.bounds
        maskLayer.path = maskPath.cgPath
        confirmBtn.layer.mask = maskLayer
        // -----
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TrainingPrefToSessionSegue"{
            let destination = segue.destination as! TrainingSessionViewController
            //destination.promptVolume = voiceLevelSlider.value
        }
    }

    // MARK: - Other Functions
    func popupWindow(title: String, message: String)
    {
        
        let alert = UIAlertController(title: "\(title)", message: message, preferredStyle: .alert)
        
        //textfield
        alert.addTextField{ (edit) in
            edit.placeholder = "Enter desired \(title)"
        }
        
        //action buttons
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
        
            let inputTxt = alert.textFields![0].text!
            if self.isInt(chkString: inputTxt){
                let uDefaults = UserDefaults.standard
                
                switch(title){
                case self.setsStr:
                    let setsAmt = alert.textFields![0].text!
                    uDefaults.setValue(setsAmt, forKey: ConstantsList.Defaults.setsDef)
                    self.formatAttributedTitleandButton(button: self.setsBtn, newTitle: "\(setsAmt) sets", newSubTitle: "Total repetitive rounds in one session")
                    break;
                case self.swingsStr:
                    let swingsAmt = alert.textFields![0].text!
                    uDefaults.setValue(swingsAmt, forKey: ConstantsList.Defaults.swingsDef)
                    self.formatAttributedTitleandButton(button: self.swingsBtn, newTitle: "\(swingsAmt) swings", newSubTitle: "Total racket swings in a set")
                    break;
                case self.delayStr:
                    let delayAmt = alert.textFields![0].text!
                    uDefaults.setValue(delayAmt, forKey: ConstantsList.Defaults.delayDef)
                    self.formatAttributedTitleandButton(button: self.delayBtn, newTitle: "\(delayAmt) sec", newSubTitle: "The delay between Swings")
                    break;
                case self.recoveryStr:
                    let recoveryAmt = alert.textFields![0].text!
                    uDefaults.setValue(recoveryAmt, forKey: ConstantsList.Defaults.recoveryDef)
                    self.formatAttributedTitleandButton(button: self.recoveryBtn, newTitle: "\(recoveryAmt) sec", newSubTitle: "The recovery time in between Sets")
                    break;
                default:
                    break;
                }
            } else {
                self.displayMessage(title: "Error", message: "Please input a number")
            }
            
        }

        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            
        })
    }
    
    func updateUIandDefaults(sets: String?, swings: String?, delay: String?, recovery: String?){
        let setsDef = ConstantsList.Defaults.setsDef
        let swingsDef = ConstantsList.Defaults.swingsDef
        let delayDef = ConstantsList.Defaults.delayDef
        let recoveryDef = ConstantsList.Defaults.recoveryDef
        
        let dSets = ConstantsList.DefaultValues.setsVal
        let dSwings = ConstantsList.DefaultValues.swingsVal
        let dDelay = ConstantsList.DefaultValues.delayVal
        let dRecovery = ConstantsList.DefaultValues.recoveryVal
        
        let uDef = UserDefaults.standard
        uDef.set(sets ?? dSets, forKey: setsDef)
        uDef.set(swings ?? dSwings, forKey: swingsDef)
        uDef.set(delay ?? dDelay, forKey: delayDef)
        uDef.set(recovery ?? dRecovery, forKey: recoveryDef)
        
        formatAttributedTitleandButton(button: setsBtn, newTitle: "\(sets ?? dSets) sets", newSubTitle: "Total repetitive rounds in one session")
        formatAttributedTitleandButton(button: swingsBtn, newTitle: "\(swings ?? dSwings) swings", newSubTitle: "Total racket swings in a set")
        formatAttributedTitleandButton(button: delayBtn, newTitle: "\(delay ?? dDelay) sec", newSubTitle: "The delay between Swings")
        formatAttributedTitleandButton(button: recoveryBtn, newTitle: "\(recovery ?? dRecovery) sec", newSubTitle: "The recovery time in between Sets")
    }
    
    func formatAttributedTitleandButton(button: UIButton, newTitle: String, newSubTitle:String){
        
        // format and set Title and Subtitle -----
        let titleStr = "\(newTitle)\n\(newSubTitle)"
        
        let titleText = NSMutableAttributedString(string: titleStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)])
        
        // format Subtitle font size and color
        titleText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: (titleStr as NSString).range(of: newSubTitle))
        //titleText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray6, range: (titleStr as NSString).range(of: newSubTitle))
        // -----
        
        //format button -----
        button.setAttributedTitle(titleText, for: .normal)
        
        button.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        button.titleLabel?.textAlignment = NSTextAlignment.center
        //-----
    }

}
