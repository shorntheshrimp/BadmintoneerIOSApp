//
//  HomeViewController.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

// MARK: - Credits
// Generic parameters - https://stackoverflow.com/questions/24380535/how-to-apply-gradient-to-background-view-of-ios-swift-app
//  Rounded corners(targeted) -  https://stackoverflow.com/questions/10316902/rounded-corners-only-on-top-of-a-uiview
// attributed strings 1 - https://stackoverflow.com/questions/39346449/how-to-set-2-lines-of-attribute-string-in-uilabel
// attributed strings 2 - https://www.hackingwithswift.com/articles/113/nsattributedstring-by-example
// youtube api v3, getting video’s data from url 1 - https://www.appcoda.com/youtube-api-ios-tutorial/
// youtube api v3, getting video’s data from url 2 - https://stackoverflow.com/questions/30290483/how-to-use-youtube-api-v3
// tableviews in normal view controllers - https://www.weheartswift.com/how-to-make-a-simple-table-view-with-ios-8-and-swift/
// saving NSObjects as NSData for User Defaults storing 1 - https://stackoverflow.com/questions/29986957/save-custom-objects-into-nsuserdefaults
// saving NSObjects as NSData for User Defaults storing 1 - https://stackoverflow.com/questions/51487622/unarchive-array-with-nskeyedunarchiver-unarchivedobjectofclassfrom

import UIKit
import FirebaseAuth
import youtube_ios_player_helper

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate {
    
    //YOUTUBE VIDEO TABLEVIEW
    //There are 9 categories of videos in the tableview, hence 9 sections
    //***If additional categories need to be added they will have to added in each overrided function
    //The properties(title, cells) of this 9 sections are hardcoded
    //Each video will be converted into a VideoObject NSObect so that it can be stored as NSData into userdefaults
    //The VideoObject NSObjects are setup to be decodable
    //Each VideoObject are hardcoded decoded videos from Youtube's API
    //***Video URL is manually hardcoded as I only want specific videos to be shown
    //A get request is made so each dequeued cell will reload the video link via YTPlayerView
    
    var VID_CELL_HEIGHT: CGFloat = 100
    
    // MARK: - Table Overriden func
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionHeader: String?
        
        switch(section){
        case 0:
            sectionHeader = "Rules"
            break
        case 1:
            sectionHeader = "Racket Selecting"
            break
        case 2:
            sectionHeader = "Fundamentals"
            break
        case 3:
            sectionHeader = "Footwork"
            break
        case 4:
            sectionHeader = "Service"
            break
        case 5:
            sectionHeader = "Smashing"
            break
        case 6:
            sectionHeader = "Singles"
            break
        case 7:
            sectionHeader = "Doubles"
            break
        case 8:
            sectionHeader = "Advanced"
            break
        default:
            sectionHeader = ""
        }
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRows: Int?
        
        switch(section){
        case 0:
            numRows = self.rulesVids.count
            break
        case 1:
            numRows = self.chooseRacketVids.count
            break
        case 2:
            numRows = self.fundamentalsVids.count
            break
        case 3:
            numRows = self.footworkVids.count
            break
        case 4:
            numRows = self.servingVideos.count
            break
        case 5:
            numRows = self.smashingVideos.count
            break
        case 6:
            numRows = self.singlesVids.count
            break
        case 7:
            numRows = self.doublesVids.count
            break
        case 8:
            numRows = self.advancedVideos.count
            break
        default:
            numRows = 0
        }
        
        return numRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = self.youtubeVideosTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.numberOfLines = 3
        
        //init youtube player view with width and height and placement
        let playerView: YTPlayerView = YTPlayerView(frame: CGRect.init(x: 0, y: 0, width: 180, height: 100))
        //playerView.sizeToFit()
        cell.addSubview(playerView)
        cell.autoresizesSubviews = true

        cell.layoutMargins.left = 200
        
        switch(indexPath.section){
        case 0:
            configVideoCell(cell: cell, videoAR: rulesVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 1:
            configVideoCell(cell: cell, videoAR: chooseRacketVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 2:
            configVideoCell(cell: cell, videoAR: fundamentalsVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 3:
            configVideoCell(cell: cell, videoAR: footworkVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 4:
            configVideoCell(cell: cell, videoAR: servingVideos, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 5:
            configVideoCell(cell: cell, videoAR: smashingVideos, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 6:
            configVideoCell(cell: cell, videoAR: singlesVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 7:
            configVideoCell(cell: cell, videoAR: doublesVids, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        case 8:
            configVideoCell(cell: cell, videoAR: advancedVideos, arIndex: indexPath.row, ytPlayerView: playerView)
            break
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uDef = UserDefaults.standard
        var decodedObj: [VideoObject] = []
        
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to bookmark this video?", preferredStyle: .alert)
        
        //action buttons
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            // get userdefaults
            if let decoded = uDef.data(forKey: ConstantsList.Defaults.bookmarkedVideosDef){
            
//                for item in decoded{
//                    let item = item as! VideoObject
//                    print("decoded item from defaults: \(item.videoTitle ?? "error")")
//                }
                // decode userdefaults to [videoobject]
                do {
                    decodedObj = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? [VideoObject])!
                    print("decoding")
                } catch {
                    print("cannot decode bookmarkedObj array")
                }
            }
            
            let video = self.getVideoObjFrom(categoryNo: indexPath.section, indexNo: indexPath.row)
            print("supposed to get \(video.videoTitle ?? "also empty...")")
            
            //check for duplicates before bookmarking
            for dObj in decodedObj{
                print("decoded last obj title: \(dObj.videoTitle ?? "no object in decodedObj Array") \(decodedObj.count) objects")
                if dObj.videoTitle == video.videoTitle || dObj.videoID == video.videoID{
                    let cell = self.youtubeVideosTableView.cellForRow(at: indexPath)
                    
                    cell?.shake()

                    self.displayMessage(title: "Duplicate Video", message: "Please choose a new video to bookmark")
                    return
                }
            }
            decodedObj.append(video)

            do{
                let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: decodedObj, requiringSecureCoding: false)
                uDef.set(encodedData, forKey: ConstantsList.Defaults.bookmarkedVideosDef)
            } catch {
                print("not. working.")
            }
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            //do smth
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            //do smth
        })
        
    }
    
    func getVideoObjFrom(categoryNo: Int, indexNo: Int) -> VideoObject{
        
        switch(categoryNo){
        case 0:
            return rulesVids[indexNo]
        case 1:
            return chooseRacketVids[indexNo]
        case 2:
            return fundamentalsVids[indexNo]
        case 3:
            return footworkVids[indexNo]
        case 4:
            return servingVideos[indexNo]
        case 5:
            return smashingVideos[indexNo]
        case 6:
            return singlesVids[indexNo]
        case 7:
            return doublesVids[indexNo]
        case 8:
            return advancedVideos[indexNo]
        default:
            return VideoObject(videoID: "", videoTitle: "", videoDescription: "", videoThumbnailurl: "", videoDuration: "")
        }
        
    }
    
    func configVideoCell(cell: UITableViewCell, videoAR: [VideoObject], arIndex: Int, ytPlayerView: YTPlayerView){
        cell.textLabel?.text = videoAR[arIndex].videoTitle
        cell.detailTextLabel?.text = videoAR[arIndex].videoDuration
        
        //next line is for inline, replaying video opens up youtube app however...
//            playerView.load(withVideoId: rulesVids[indexPath.row].videoID!, playerVars: ["playsinline": 1])
        //next line is without inline , still opens up youtube subsequently
        ytPlayerView.load(withVideoId: videoAR[arIndex].videoID!)

        // solution: use loadVideoByURL instead of VideoId
        // this stops youtube from opening after resuming playback
        // edit: nvm embedded link doesn't work...
        //let mainYTURL = "https://www.youtube.com/embed/"
        //playerView.loadVideo(byURL: "\(mainYTURL)\(rulesVids[indexPath.row].videoID!)", startSeconds: .zero)
    }
    
    // MARK: - Main View Controller
    
    var rulesVids: [VideoObject] = []
    var chooseRacketVids: [VideoObject] = []
    var fundamentalsVids: [VideoObject] = []
    var footworkVids: [VideoObject] = []
    var servingVideos: [VideoObject] = []
    var smashingVideos: [VideoObject] = []
    var singlesVids: [VideoObject] = []
    var doublesVids: [VideoObject] = []
    var advancedVideos: [VideoObject] = []
    
    @IBOutlet weak var youtubeVideosTableView: UITableView!
    @IBOutlet weak var trainingHistoryTitleLabel: UILabel!
    @IBOutlet weak var TotalSetsTitleLabel: UILabel!
    @IBOutlet weak var TotalSwingsTitleLabel: UILabel!
    @IBOutlet weak var TotalSetsEarnedLabel: UILabel!
    @IBOutlet weak var TotalSwingsEarnedLabel: UILabel!
    @IBOutlet weak var bookmarkToolTipLabel: UILabel!
    
    @IBOutlet weak var historySV: UIStackView!
    @IBOutlet weak var trainingBtn: UIButton!
    @IBAction func trainingBtnPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        //other setups -----
        bookmarkToolTipLabel.text = "Click on cell below to bookmark video"
        bookmarkToolTipLabel.textColor = .systemGray3
        // -----
        
        //setting up videos table view -----
        youtubeVideosTableView.delegate = self
        youtubeVideosTableView.dataSource = self
        
        self.youtubeVideosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.youtubeVideosTableView.rowHeight = VID_CELL_HEIGHT
        
        // -----
        
        // set top text from user defaults -----
        trainingHistoryTitleLabel.text = "Training History"
        TotalSetsTitleLabel.text = "Total Sets Completed"
        TotalSwingsTitleLabel.text = "Total Swings Completed"
        
        let uDef = UserDefaults.standard
        
        TotalSetsEarnedLabel.text = uDef.string(forKey: ConstantsList.Defaults.setsEarnedDef)
        TotalSwingsEarnedLabel.text = uDef.string(forKey: ConstantsList.Defaults.swingsEarnedDef)
        // -----
        
        // customize top stack views -----
        historySV.customizeStackView(backgroundColor: UIColor.systemBlue, radiusSize: 10)
        historySV.backgroundColor = UIColor.systemBackground
        historySV.spacing = 10
        
        trainingBtn.setTitle("Start Training Session >>>", for: .normal)
        trainingBtn.backgroundColor = .systemGreen
        trainingBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21)
        trainingBtn.layer.cornerRadius = 10
        let maskPath = UIBezierPath(roundedRect: trainingBtn.bounds,
                    byRoundingCorners: [.topRight , .bottomRight],
                    cornerRadii: CGSize(width: 50, height: 50))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = trainingBtn.bounds
        maskLayer.path = maskPath.cgPath
        trainingBtn.layer.mask = maskLayer
        // -----
        
        performGetRequest(videoID: "yaeFQ8lxR9M"){ videoObj in
            self.rulesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "UyLIi-TbcFc"){ videoObj in
            self.rulesVids.append(videoObj)
            
            var i: Int = 0
            for item in self.rulesVids{
                i += 1
                print("rulesVids \(i) title: \((item.videoTitle) ?? "error")")
            }
            
            self.youtubeVideosTableView.reloadData()
        }
        
        performGetRequest(videoID: "GckLu21RwcM"){ videoObj in
            self.chooseRacketVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "F_-0pHH8mSI"){ videoObj in
            self.chooseRacketVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }

        performGetRequest(videoID: "toQ7tOx7Tvs"){ videoObj in
            self.fundamentalsVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "S2-G_tbIj80"){ videoObj in
            self.fundamentalsVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "1UIhKZCPMYM"){ videoObj in
            self.fundamentalsVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "07x6-qippgo"){ videoObj in
            self.fundamentalsVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        
        performGetRequest(videoID: "mWK76ZDDFZQ"){ videoObj in
            self.footworkVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "PGwrspAkO0E"){ videoObj in
            self.footworkVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        
        performGetRequest(videoID: "O4X0LL7t2ys"){ videoObj in
            self.servingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "kzWpvuWeih0"){ videoObj in
            self.servingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "d8J4hyO20XA"){ videoObj in
            self.servingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "VAciL9gcgOY"){ videoObj in
            self.servingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "U2mHCoja9XM"){ videoObj in
            self.servingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        
        performGetRequest(videoID: "Px5XUqcvyXc"){ videoObj in
            self.smashingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "HvAOMnoT3zQ"){ videoObj in
            self.smashingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "AGY-gQ_3O8Y"){ videoObj in
            self.smashingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "B-HTD-feYRk"){ videoObj in
            self.smashingVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        
        performGetRequest(videoID: "4E3Uqc7HflQ"){ videoObj in
            self.singlesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "suU1OAmFo1Y"){ videoObj in
            self.singlesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "FTI1u3vRpRI"){ videoObj in
            self.singlesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "oH9czi7OW5c"){ videoObj in
            self.singlesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }

        performGetRequest(videoID: "EeWABDrlma8"){ videoObj in
            self.doublesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "ynmyWE3N0Wc"){ videoObj in
            self.doublesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "CRizHMcXgLo"){ videoObj in
            self.doublesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "k__HuDs_2hE"){ videoObj in
            self.doublesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "GF342PDIM0Q"){ videoObj in
            self.doublesVids.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }

        performGetRequest(videoID: "6s3z3UT1Mbk"){ videoObj in
            self.advancedVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "92gCzJBNLcI"){ videoObj in
            self.advancedVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "sJPBuUDGqGg"){ videoObj in
            self.advancedVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "sXwcmK14_YE"){ videoObj in
            self.advancedVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }
        performGetRequest(videoID: "40jBC98xTRE"){ videoObj in
            self.advancedVideos.append(videoObj)
            self.youtubeVideosTableView.reloadData()
        }

    }
    
    // MARK: - Functions
    
    
    func performGetRequest(videoID: String?, completionBlock: @escaping (_ videoObj : VideoObject) ->Void){
        
            //var dataArray = [[String: AnyObject]]()
            // store videoid , thumbnial , Title , Description

            let API_KEY = "AIzaSyAru3frmL6bgrCFqP0m0mHQn47sAg4AB-E"

             // create api key from google developer console for youtube
        
                var urlString = "https://www.googleapis.com/youtube/v3/videos?id=\(videoID ?? "")&key=\(API_KEY)&part=snippet,contentDetails"

                //example url format
                //https://www.googleapis.com/youtube/v3/videos?id=yaeFQ8lxR9M&key=AIzaSyAru3frmL6bgrCFqP0m0mHQn47sAg4AB-E&part=snippet,contentDetails
        
                urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
                let targetURL = URL(string: urlString)

                let config = URLSessionConfiguration.default // Session Configuration
                let session = URLSession(configuration: config)

                let task = session.dataTask(with: targetURL!) {

                    data, response, error in

                    DispatchQueue.main.async{
                    
                    if error != nil {

                        print(error!.localizedDescription)
                        return

                    }

                    else {
                        do {
                            typealias JSONObject = [String:AnyObject]

                            let  json = try JSONSerialization.jsonObject(with: data!, options: []) as! JSONObject
                            let items  = json["items"] as! Array<JSONObject>
                            print ("items found: \(items.count)")

                            //not iterating since only need first result aka index[0]
                            //for i in 0 ..< 1 {

                                let snippetDictionary = items[0]["snippet"] as! JSONObject
                                //print(snippetDictionary)
                                let contentDetailsDictionary = items[0]["contentDetails"] as! JSONObject
                                // Initialize a new dictionary and store the data of interest.
                                var youVideoDict = JSONObject()

                                youVideoDict["title"] = snippetDictionary["title"]
                                youVideoDict["description"] = snippetDictionary["description"]
                                youVideoDict["thumbnailurl"] = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"]
                                youVideoDict["duration"] = contentDetailsDictionary["duration"]
                                youVideoDict["id"] = items[0]["id"]
                                
                                let videoObj = VideoObject(videoID: "", videoTitle: "", videoDescription: "", videoThumbnailurl: "", videoDuration: "")
                                
                                let titleStr : String = snippetDictionary["title"] as? String ?? ""
                                let descStr : String = snippetDictionary["description"] as? String ?? ""
                                let thumbnailurlStr : String = ((snippetDictionary["thumbnails"] as! JSONObject)["high"] as! JSONObject)["url"] as? String ?? ""
                                let durationStr : String = contentDetailsDictionary["duration"] as? String ?? ""
                                let idStr : String = items[0]["id"] as? String ?? ""
                                
                                videoObj.videoTitle = titleStr
                                videoObj.videoDescription = descStr
                                videoObj.videoThumbnailurl = thumbnailurlStr
                                videoObj.videoDuration = durationStr.getYoutubeFormattedDuration()
                                videoObj.videoID = idStr
                            
                                completionBlock(videoObj)
                                
                                //dataArray.append(youVideoDict)

                                // video like can get by videoID.

                            //}

                        }

                        catch {
                            print("json error: \(error)")
                        }

                    }
                    }
                }
                task.resume()

    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

    // MARK: - Extensions

extension UIStackView {
    func customizeStackView(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)

        subView.applyGradient(colours: [.clear, .systemTeal, .systemBlue], locations: [0.0, 2.0, 0.5])
        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}

extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

extension String {

    // convert youtube date formats into readable date format HH:SS
func getYoutubeFormattedDuration() -> String {

    let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")

    let components = formattedDuration.components(separatedBy: ":")
    var duration = ""
    for component in components {
        duration = duration.count > 0 ? duration + ":" : duration
        if component.count < 2 {
            duration += "0" + component
            continue
        }
        duration += component
    }

    return duration

}

}
