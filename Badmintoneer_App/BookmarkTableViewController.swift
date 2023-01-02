//
//  BookmarkTableViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 6/5/21.
//

import UIKit
import youtube_ios_player_helper

class BookmarkTableViewController: UITableViewController {

    var VID_CELL_HEIGHT: CGFloat = 100
    var bookmarkedVideosAR: [VideoObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = VID_CELL_HEIGHT
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // get userdefaults
        let uDef = UserDefaults.standard
        var decodedObj: [VideoObject] = []
        
        if let decoded = uDef.data(forKey: ConstantsList.Defaults.bookmarkedVideosDef){
        
            do {
                decodedObj = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [VideoObject])!
                
                bookmarkedVideosAR = decodedObj
                for item in bookmarkedVideosAR{
                    print("\(item.videoTitle ?? "") found")
                }
                print("decoding")
                self.tableView.reloadData()
            } catch {
                print("cannot decode bookmarkedObj array")
            }
        }
        
        self.tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        var rowCount = 0
        
        if bookmarkedVideosAR.isEmpty == false{
            rowCount = bookmarkedVideosAR.count
        }

        return rowCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath ) as UITableViewCell

        // Configure the cell...
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.numberOfLines = 3
        
        //init youtube player view with width and height and placement
        let playerView: YTPlayerView = YTPlayerView(frame: CGRect.init(x: 0, y: 0, width: 180, height: 100))
        //playerView.sizeToFit()
        cell.addSubview(playerView)
        cell.autoresizesSubviews = true

        cell.layoutMargins.left = 200
        
        if bookmarkedVideosAR.isEmpty == false{
            cell.textLabel?.text = bookmarkedVideosAR[indexPath.row].videoTitle
            cell.detailTextLabel?.text = bookmarkedVideosAR[indexPath.row].videoDuration
        
            playerView.load(withVideoId: bookmarkedVideosAR[indexPath.row].videoID ?? "")
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            bookmarkedVideosAR.remove(at: indexPath.row)
            
            // get userdefaults
            let uDef = UserDefaults.standard
            
            uDef.removeObject(forKey: ConstantsList.Defaults.bookmarkedVideosDef)
                
            do{
                let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: bookmarkedVideosAR, requiringSecureCoding: false)
                    uDef.set(encodedData, forKey: ConstantsList.Defaults.bookmarkedVideosDef)
            } catch {
                print("not. working.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
    
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
