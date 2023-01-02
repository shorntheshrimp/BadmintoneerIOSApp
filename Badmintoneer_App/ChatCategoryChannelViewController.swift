//
//  ChatCategoryChannelViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 11/6/21.
//

import UIKit

class ChatCategoryChannelViewController: UIViewController {
    
    //There are 4 category channels for the player to choose from
    //These category channels are set beforehand and cannot be editted or removed by a normal user

    let CAT_TO_MAIN_SEGUE = "CategoryChannelToMainSegue"
    var channelCat : String?
    
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var BadmintonBanterBtn: UIButton!
    @IBOutlet weak var GameplayBtn: UIButton!
    @IBOutlet weak var RASBtn: UIButton!
    @IBOutlet weak var OtherEQBtn: UIButton!
    @IBAction func BadmintonBanterPressed(_ sender: Any) {
        channelCat = "badmintonbanter"
        performSegue(withIdentifier: CAT_TO_MAIN_SEGUE, sender: self)
    }
    @IBAction func GameplayPressed(_ sender: Any) {
        channelCat = "gameplay"
        performSegue(withIdentifier: CAT_TO_MAIN_SEGUE, sender: self)
    }
    @IBAction func RASPressed(_ sender: Any) {
        channelCat = "racketsandshuttlecocks"
        performSegue(withIdentifier: CAT_TO_MAIN_SEGUE, sender: self)
    }
    @IBAction func OtherEQPressed(_ sender: Any) {
        channelCat = "otherequipment"
        performSegue(withIdentifier: CAT_TO_MAIN_SEGUE, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatAttributedTitleandButton(button: BadmintonBanterBtn, newTitle: "Badminton Banter", newSubTitle: "That sick shot from THAT match... let's talk about that", bgcolor: .systemPink, cornerRadius: 10)
        formatAttributedTitleandButton(button: GameplayBtn, newTitle: "Game Play", newSubTitle: "From dropshots to smashing... anything goes!", bgcolor: .systemPurple, cornerRadius: 10)
        formatAttributedTitleandButton(button: RASBtn, newTitle: "Rackets & ShuttleCocks", newSubTitle: "Can't figure out which one to buy? Discuss away!", bgcolor: .systemBlue, cornerRadius: 10)
        formatAttributedTitleandButton(button: OtherEQBtn, newTitle: "Other Equipment", newSubTitle: "Shoes... check. Wristbands... check?", bgcolor: .systemGreen, cornerRadius: 10)
        
        // Do any additional setup after loading the view.
        noticeLabel.text = "Please be kind to other users. Toxic Behavior will not be tolerated."
        noticeLabel.textColor = UIColor.systemGray2
        noticeLabel.textAlignment = NSTextAlignment.center
        noticeLabel.numberOfLines = 0
        noticeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    func formatAttributedTitleandButton(button: UIButton, newTitle: String, newSubTitle:String, bgcolor : UIColor, cornerRadius : CGFloat){
        
        // format and set Title and Subtitle -----
        let titleStr = "\(newTitle)\n\(newSubTitle)"
        
        let titleText = NSMutableAttributedString(string: titleStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        
        // format Subtitle font size and color
        titleText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10), range: (titleStr as NSString).range(of: newSubTitle))
        //titleText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGray6, range: (titleStr as NSString).range(of: newSubTitle))
        // -----
        
        //format button -----
        button.setAttributedTitle(titleText, for: .normal)
        
        button.titleEdgeInsets = UIEdgeInsets(top: 20,left: 20,bottom: 20,right: 20)
        
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        button.titleLabel?.textAlignment = .left
        
        button.contentHorizontalAlignment = .leading
        
        button.backgroundColor = bgcolor
        
        button.layer.cornerRadius = cornerRadius
        //-----
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == CAT_TO_MAIN_SEGUE{
            let destination = segue.destination as! ChatMainChannelTableViewController
            destination.channelCat = self.channelCat
        }
    }

}
