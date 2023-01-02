//
//  ChatMainChannelTableViewController.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 27/5/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatMainChannelTableViewController: UITableViewController {
    
    //Within each category, users can create chat channels and interact with other users
    //Only users that create the specific chat channel can delete it
    //The user that created the chat channel will be seen on the channel cell
    
    let SEGUE_CHANNEL = "channelSegue"
    let CELL_CHANNEL = "channelCell"
    
    let BADMINTONB_CAT = "badmintonbanter"
    let GAMEPLAY_CAT = "gameplay"
    let RACANDSHUT_CAT = "racketsandshuttlecocks"
    let OTHEREQ_CAT = "otherequipment"
    
    var indicator = UIActivityIndicatorView()
    
    var channelCat : String?
    var currentSender : Sender?
    var channels = [Channel]()
    var channelsRef : CollectionReference?
    
    var databaseListener: ListenerRegistration?

    @IBAction func addChannelPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Channel", message: "Enter channel name below", preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            let channelName = alertController.textFields![0]
            var doesExist = false
            
            for channel in self.channels {
                if channel.name.lowercased() == channelName.text!.lowercased() {
                    doesExist = true
                }
            }
            if !doesExist {
                self.channelsRef?.addDocument(data: ["name" : channelName.text!, "category" : self.channelCat!, "authorname" : (self.currentSender?.displayName)!, "authorid" : (self.currentSender?.senderId)!])
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        
        //change navigation title
        print(channelCat ?? "channelCat: No String carried over")
        
        switch(channelCat){
        case BADMINTONB_CAT:
            self.title = "Badminton Banter"
            break
        case GAMEPLAY_CAT:
            self.title = "Gameplay"
            break
        case RACANDSHUT_CAT:
            self.title = "Rackets and Shuttlecocks"
            break
        case OTHEREQ_CAT:
            self.title = "Other Equipment"
            break
        default:
            self.title = "Chat Channel"
        }
        
        //get user info from database
        getUserData(completionHander: {
            let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
                if let uid = user?.uid{
                    let nameDef = UserDefaults.standard.string(forKey: ConstantsList.Defaults.nameDef)
                    
                    self.currentSender = Sender(id: uid, name: nameDef ?? "")
                }
            }
            Auth.auth().removeStateDidChangeListener(listener)
        })
        
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        indicator.startAnimating()
        
        databaseListener = channelsRef?.addSnapshotListener(){
            (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.channels.removeAll()
            querySnapshot?.documents.forEach() { snapshot in
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let category = snapshot["category"] as? String
                let authorname = snapshot["authorname"] as? String
                let authorid = snapshot["authorid"] as? String
                let channel = Channel(id: id, name: name, category: category ?? "", authorname: authorname ?? "", authorid: authorid ?? "")
                
                if category == self.channelCat{
                    self.channels.append(channel)
                }
                
                self.tableView.reloadData()
            }
            self.indicator.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHANNEL, for: indexPath)

        // Configure the cell...
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.text = channels[indexPath.row].name

        cell.detailTextLabel?.textColor = UIColor.systemGray2
        cell.detailTextLabel?.text = "Creater: \(channels[indexPath.row].authorname)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: SEGUE_CHANNEL, sender: channel)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if channels[indexPath.row].authorid == currentSender?.senderId {
                
                let alert = UIAlertController(title: "Confirmation", message: "Do you want to delete this chat channel?(This action cannot be reversed!))", preferredStyle: .alert)
                
                //action buttons
                let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
                    
                    self.indicator.startAnimating()
                    
                    let db = Firestore.firestore()
                    db.collection("channels").document(self.channels[indexPath.row].id).delete(){ err in
                        if let err = err {
                            print("Cannot remove document: \(err)")
                            self.indicator.stopAnimating()
                        } else {
                            DispatchQueue.main.async {
                                print("Document removed!")
                        
                                self.indicator.stopAnimating()
                            }
                        }
                    }
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
                    
                }
                
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
                    
                })
                
            } else {
                displayMessage(title: "Error", message: "Only the Creater can delete this channel.")
            }

        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == SEGUE_CHANNEL {
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChatMessagesViewController
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
       }
    }

}
