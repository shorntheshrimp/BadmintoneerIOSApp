//
//  TrainingSessionViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 2/6/21.
//

// MARK: - Credits
// timer - https://www.youtube.com/watch?v=3TbdoVhgQmE
// random enums - https://stackoverflow.com/questions/26261011/how-to-choose-a-random-enumeration-value
// Reset current VC embedded in nav controller - https://stackoverflow.com/questions/30633566/how-to-reset-restart-viewcontroller-in-swift/40172257
// Accelerometer - https://www.youtube.com/watch?v=XDuchXYiWuE
// play audio - https://www.hackingwithswift.com/example-code/media/how-to-play-sounds-using-avaudioplayer

import UIKit
import CoreMotion
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

class TrainingSessionViewController: UIViewController {
    
    //The actual training session
    //This is a timer based simulation based on settings made in the previous VC(TrainingParametersViewController AKA Preferences)
    //Each section(9 in total) will be called randomly via enums
    //The voice prompts will correspond to the section generated
    
    //In order for user to make a successful swing (a acceleration factor > 5)
    //Each swing is being calculated every 0.2 seconds
    
    //Once a session has been completed(all sets completed), the session values(sets and success swings) will be recorded for the user via firestore

    var indicator = UIActivityIndicatorView()
    
    let cmManager = CMMotionManager()
    
    let uDef = UserDefaults.standard

    var isPaused: Bool = false
    var timerVar = 0
    var timer = Timer()
    
    var mSets: Int = 0
    var mSwings: Int = 0
    var mDelay: Int = 0
    var mRecovery: Int = 0
    
    var setCount: Int = 0
    var currSetDone: Bool = false
    var swingCount: Int = 0
    var successSwings: Int = 0
    
    var canSwing: Bool = false
    
    var allCourtIV = [UIImageView]()
    var randIV: UIImageView?
    
    var promptSound: AVAudioPlayer?
    var promptVolume: Float = 0.0
    
    @IBOutlet weak var FrontLeftIV: UIImageView!
    @IBOutlet weak var FrontIV: UIImageView!
    @IBOutlet weak var FrontRightIV: UIImageView!
    @IBOutlet weak var MidLeftIV: UIImageView!
    @IBOutlet weak var MidIV: UIImageView!
    @IBOutlet weak var MidRightIV: UIImageView!
    @IBOutlet weak var BackLeftIV: UIImageView!
    @IBOutlet weak var BackIV: UIImageView!
    @IBOutlet weak var BackRightIV: UIImageView!
    
    @IBOutlet weak var successfulSwingsLabel: UILabel!
    @IBOutlet weak var sessionNoticeLabel: UILabel!
    @IBOutlet weak var blackOverlayIV: UIImageView!
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
    @IBOutlet weak var retryBtn: UIButton!
    @IBAction func retryBtnPressed(_ sender: Any) {
        
        isPaused = true
        timer.invalidate()
        cmManager.stopAccelerometerUpdates()
        
        let alert = UIAlertController(title: "Warning", message: "Do you want to restart?(Current progress will not be recorded.)", preferredStyle: .alert)
        
        //action buttons
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.resetVC()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TrainingSessionViewController.increTimer), userInfo: nil, repeats: true)
            self.isPaused = false
            self.startAccel()
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            
        })
    }
    @IBOutlet weak var pauseBtn: UIButton!
    @IBAction func pauseBtnPressed(_ sender: Any) {
        
        if(isPaused)
        {
            isPaused = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TrainingSessionViewController.increTimer), userInfo: nil, repeats: true)
            startAccel()
            
            blackOverlayIV.isHidden = true
            
            customiseBtn(view: pauseBtn, imgName: "pause.fill", bgColor: .systemPink, scale: 1.5)
        } else {
            isPaused = true
            timer.invalidate()
            cmManager.stopAccelerometerUpdates()
            
            blackOverlayIV.isHidden = false
            
            customiseBtn(view: pauseBtn, imgName: "play.fill", bgColor: .systemGreen, scale: 1.5)
        }
        
    }
    @IBOutlet weak var homeBtn: UIButton!
    @IBAction func homeBtnPressed(_ sender: Any) {
        
        self.timerVar = 0
        timer.invalidate()
        cmManager.stopAccelerometerUpdates()
        
        transitionToMenu(viewCon: MainTabBarViewController.self, viewID: ConstantsList.Storyboard.mainTBVC)
    }
    
    // MARK: - Overriden Func
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Other init -----
        promptVolume = UserDefaults.standard.float(forKey: ConstantsList.TempValues.volumeTemp)
        sessionNoticeLabel.text = ""
        successfulSwingsLabel.text = "Successful Swings: 0"
        // -----
        
        // Indicator ring -----
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
        // -----
        
        //hide court play area boxes -----
        FrontLeftIV.alpha = 0.0
        FrontIV.alpha = 0.0
        FrontRightIV.alpha = 0.0
        MidLeftIV.alpha = 0.0
        MidIV.alpha = 0.25
        MidRightIV.alpha = 0.0
        BackLeftIV.alpha = 0.0
        BackIV.alpha = 0.0
        BackRightIV.alpha = 0.0
        
        allCourtIV.append(FrontLeftIV)
        allCourtIV.append(FrontIV)
        allCourtIV.append(FrontRightIV)
        allCourtIV.append(MidLeftIV)
        allCourtIV.append(MidRightIV)
        allCourtIV.append(BackLeftIV)
        allCourtIV.append(BackIV)
        allCourtIV.append(BackRightIV)
        // -----
        
        //black overlay img for pausing -----
        blackOverlayIV.backgroundColor = UIColor.black
        blackOverlayIV.alpha = 0.75
        blackOverlayIV.isHidden = true
        // -----
        
        //set session variables from User Defaults -----
        let dSets = uDef.string(forKey: ConstantsList.DefaultValues.setsVal)
        let dSwings = uDef.string(forKey: ConstantsList.DefaultValues.swingsVal)
        let dDelay = uDef.string(forKey: ConstantsList.DefaultValues.delayVal)
        let dRecovery = uDef.string(forKey: ConstantsList.DefaultValues.recoveryVal)
        
        mSets = Int(((uDef.string(forKey: ConstantsList.Defaults.setsDef)) ?? dSets)!)!
        mSwings = Int(((uDef.string(forKey: ConstantsList.Defaults.swingsDef)) ?? dSwings)!)!
        mDelay = Int(((uDef.string(forKey: ConstantsList.Defaults.delayDef)) ?? dDelay)!)!
        mRecovery = Int(((uDef.string(forKey: ConstantsList.Defaults.recoveryDef)) ?? dRecovery)!)!
        // -----
        
        // Style 3 option buttons at the bottom -----
        customiseBtn(view: retryBtn, imgName: "arrow.clockwise", bgColor: .systemOrange, scale: 2.0)
        
        customiseBtn(view: pauseBtn, imgName: "pause.fill", bgColor: .systemPink, scale: 1.5)
        
        customiseBtn(view: homeBtn, imgName: "house.fill", bgColor: .systemBlue, scale: 2.0)
        // -----
        
        // Timer for court boxes -----
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TrainingSessionViewController.increTimer), userInfo: nil, repeats: true)
        // -----
        
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Motion Sensor init -----
        startAccel()
        // -----
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // MARK: - Court enums
    enum courtSection: UInt32 {
        case FrontLeft
        case Front
        case FrontRight
        case MidLeft
        case MidRight
        case BackLeft
        case Back
        case BackRight

        private static let _count: courtSection.RawValue = {
            // find the maximum enum value
            var maxValue: UInt32 = 0
            while let _ = courtSection(rawValue: maxValue) {
                maxValue += 1
            }
            return maxValue
        }()

        static func randomSection() -> courtSection {
            // pick and return a new value
            let rand = arc4random_uniform(_count)
            return courtSection(rawValue: rand)!
        }
    }
    
    // MARK: - Functions
    @objc func increTimer(){
        
        if (currSetDone == false){
            
            if ((promptSound?.isPlaying) != nil){
                promptSound?.stop()
            }
            
            if timerVar == mDelay {
                
                canSwing = true
                
                swingCount += 1
                
                switch courtSection.randomSection() {
                case .FrontLeft:
                    FrontLeftIV.alpha = 1.0
                    randIV = FrontLeftIV
                    playPrompt(resource: ConstantsList.AudioFiles.frontleft)
                    break
                case .Front:
                    FrontIV.alpha = 1.0
                    randIV = FrontIV
                    playPrompt(resource: ConstantsList.AudioFiles.front)
                    break
                case .FrontRight:
                    FrontRightIV.alpha = 1.0
                    randIV = FrontRightIV
                    playPrompt(resource: ConstantsList.AudioFiles.frontright)
                    break
                case .MidLeft:
                    MidLeftIV.alpha = 1.0
                    randIV = MidLeftIV
                    playPrompt(resource: ConstantsList.AudioFiles.midleft)
                    break
                case .MidRight:
                    MidRightIV.alpha = 1.0
                    randIV = MidRightIV
                    playPrompt(resource: ConstantsList.AudioFiles.midright)
                    break
                case .BackLeft:
                    BackLeftIV.alpha = 1.0
                    randIV = BackLeftIV
                    playPrompt(resource: ConstantsList.AudioFiles.backleft)
                    break
                case .Back:
                    BackIV.alpha = 1.0
                    randIV = BackIV
                    playPrompt(resource: ConstantsList.AudioFiles.back)
                    break
                case .BackRight:
                    BackRightIV.alpha = 1.0
                    randIV = BackRightIV
                    playPrompt(resource: ConstantsList.AudioFiles.backright)
                    break
                }
            }
            
            if timerVar > mDelay {
                
                randIV?.alpha = 0.0
//                for item in allCourtIV{
//                    item.alpha = 0.0
//                }
                
                timerVar = 0
                
                canSwing = false
                
                promptSound?.stop()
                
                if swingCount >= mSwings {
                    swingCount = 0
                    setCount += 1
                    currSetDone = true
                    playPrompt(resource: ConstantsList.AudioFiles.recover)
                }
            }
            
        } else {
            if (timerVar > mRecovery){
                timerVar = 0
                currSetDone = false
                
                if ((promptSound?.isPlaying) != nil){
                    promptSound?.stop()
                }
                
                playPrompt(resource: ConstantsList.AudioFiles.getready)
            }
        }
        
        if setCount >= mSets {
            timer.invalidate()
            isPaused = true
            
            self.indicator.startAnimating()
            
            let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let uid = user?.uid{
                    
                    let db = Firestore.firestore()
//                    let docRef = db.collection("users").document(uid)
                    
                    let userDef = UserDefaults.standard
                    
                    let setsEarnedKey = ConstantsList.FirestoreKeys.setsEarnedKey
                    let swingsEarnedKey = ConstantsList.FirestoreKeys.swingsEarnedKey
                    
                    let setsEarnedDef = userDef.integer(forKey: ConstantsList.Defaults.setsEarnedDef) + Int(self.mSets)
                    let swingsEarnedDef = userDef.integer(forKey: ConstantsList.Defaults.swingsEarnedDef) + Int(self.successSwings)
                    userDef.set("\(setsEarnedDef)", forKey: ConstantsList.Defaults.setsEarnedDef)
                    userDef.set("\(swingsEarnedDef)", forKey: ConstantsList.Defaults.swingsEarnedDef)
                    
                    print("sets earned in session: \(setsEarnedDef)")
                    print("swings earned in session: \(swingsEarnedDef)")
                    
                    db.collection("users").document(uid).setData([
                        setsEarnedKey : setsEarnedDef, swingsEarnedKey : swingsEarnedDef
                    ], merge: true)
                    { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.indicator.stopAnimating()
                            self.displayMessage(title: "Error", message: "Could not save changes to database")
                            return
                        }
                            
                        DispatchQueue.main.async {
                                
                            print("Document successfully written!")
                            
                            self.getUserData(completionHander: {
                                
                                let alert = UIAlertController(title: "Finished!", message: "You have finished your session! Good Job!", preferredStyle: .alert)
                                
                                //action buttons
                                let retry = UIAlertAction(title: "Retry", style: .default, handler:{ (alertOKAction) in
                                    self.resetVC()
                                })
                                
                                let backtopref = UIAlertAction(title: "Change Session Preferences", style: .default, handler:{ (alertOKAction) in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                
                                let backtohome = UIAlertAction(title: "Return to Home", style: .cancel) { (_) in
                                    self.timerVar = 0
                                    self.transitionToMenu(viewCon: MainTabBarViewController.self, viewID: ConstantsList.Storyboard.mainTBVC)
                                }
                                
                                alert.addAction(retry)
                                alert.addAction(backtopref)
                                alert.addAction(backtohome)
                                
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
                                    
                                })
                                
                            })
                        
                            self.indicator.stopAnimating()
                        }
                    }
                }
            }
            Auth.auth().removeStateDidChangeListener(listener)
        }

        print("Timer: \(timerVar)")
        print("Swings: \(swingCount)")
        print("Sets: \(setCount)")
        print("Curr Set Finished: \(currSetDone)")
        
        reloadSNLabel(onRecovery: currSetDone)
        
        timerVar += 1

    }
    
    func customiseBtn(view: UIButton, imgName: String, bgColor: UIColor, scale: CGFloat){
        let image = UIImage(systemName: imgName)?.withRenderingMode(.alwaysTemplate)
        view.setImage(image, for: .normal)
        view.imageView?.layer.transform = CATransform3DMakeScale(scale, scale, scale)
        view.tintColor = UIColor.white
        view.setTitle("", for: .normal)
        view.backgroundColor = bgColor
        view.layer.cornerRadius = 10
    }
    
    func fadeInOutIV(IVArray: [UIImageView], alpha: CGFloat){
        for IVItem in IVArray{
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                IVItem.alpha = alpha
            })
        }
    }
    
    func resetVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ConstantsList.Storyboard.trainingSessVC)
        var viewcontrollers = self.navigationController!.viewControllers
        viewcontrollers.removeLast()
        viewcontrollers.append(vc)
        self.navigationController?.setViewControllers(viewcontrollers, animated: true)
    }
    
    func reloadSNLabel(onRecovery: Bool){
        
        var labeltxt: String?
        
        if onRecovery == true{
            labeltxt = "Set Count: \(setCount), Swing Count: \(swingCount), Break: \(timerVar)"
        } else {
            labeltxt = "Set Count: \(setCount), Swing Count: \(swingCount)"
        }
        
        sessionNoticeLabel.text = labeltxt
    }
    
    func playPrompt(resource: String){
        // Audiofor court prompts -----
        let path = Bundle.main.path(forResource: resource, ofType: "mp3")!
        let url = URL(fileURLWithPath: path)

        do {
            promptSound = try AVAudioPlayer(contentsOf: url)
            promptSound?.setVolume(promptVolume, fadeDuration: 0)
            promptSound?.play()
        } catch {
            // couldn't load file :(
            print("sound cannot be played")
        }
        // -----
    }
    
    func startAccel(){
        cmManager.accelerometerUpdateInterval = 0.2
        
        cmManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data{
                if myData.acceleration.x >= 5, self.canSwing{
                    self.successSwings += 1
                    self.successfulSwingsLabel.text = "Successful Swings: \(self.successSwings)"
                    print ("Good Swing!")
                }
            }
            
        }
    }

}
