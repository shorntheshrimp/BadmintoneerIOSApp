//
//  RegistrationProfileImageViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 5/5/21.
//

import UIKit

class RegistrationProfileImageViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBAction func ChangeImagePressed(_ sender: Any) {
        presentImageActionSheet()
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
        //saves chosen picture into userdefaults
        let defaults = UserDefaults.standard
        let image = profileImageView.image
        let imageData : NSData = image!.jpegData(compressionQuality: 0.5)! as NSData
        
        defaults.set(imageData, forKey: ConstantsList.Defaults.profilePicDef)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.alpha = 0
        
        profileImageView.layer.borderColor = UIColor.black.cgColor
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "RegProfileImageToBioSegue"{
//            let destination = segue.destination as? RegistrationBioViewController
        }
    }
    

}

extension RegistrationProfileImageViewController : UIImagePickerControllerDelegate {
    
    func presentImageActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Image",
                                            message: "Select a method to change Profile Image",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take a Pictue (not yet implemented)",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Choose an Image",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                            }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profileImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showErrorMsg(_ message : String){
        errorLabel.text = message
        errorLabel.alpha = 1
        UIView.animate(withDuration: 1.5, delay: 5, animations: {
            self.errorLabel.alpha = 0
        })
        
        errorLabel.shake()
    }
}
