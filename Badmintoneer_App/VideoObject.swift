//
//  VideoObject.swift
//  Badmintoneer_App
//
//  Created by Shawn Tham on 5/6/21.
//

import UIKit

class VideoObject: NSObject, Decodable, NSCoding {
    var videoID: String?
    var videoTitle: String?
    var videoDescription: String?
    var videoThumbnailurl: String?
    var videoDuration: String?
    
    init(videoID: String, videoTitle: String, videoDescription: String, videoThumbnailurl: String, videoDuration: String) {
            self.videoID = videoID
            self.videoTitle = videoTitle
            self.videoDescription = videoDescription
            self.videoThumbnailurl = videoThumbnailurl
            self.videoDuration = videoDuration
        }

        required convenience init(coder aDecoder: NSCoder) {
            let videoID = aDecoder.decodeObject(forKey: "videoID") as! String
            let videoTitle = aDecoder.decodeObject(forKey: "videoTitle") as! String
            let videoDescription = aDecoder.decodeObject(forKey: "videoDescription") as! String
            let videoThumbnailurl = aDecoder.decodeObject(forKey: "videoThumbnailurl") as! String
            let videoDuration = aDecoder.decodeObject(forKey: "videoDuration") as! String
            self.init(videoID: videoID, videoTitle: videoTitle, videoDescription: videoDescription, videoThumbnailurl: videoThumbnailurl, videoDuration: videoDuration)
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(videoID, forKey: "videoID")
            aCoder.encode(videoTitle, forKey: "videoTitle")
            aCoder.encode(videoDescription, forKey: "videoDescription")
            aCoder.encode(videoThumbnailurl, forKey: "videoThumbnailurl")
            aCoder.encode(videoDuration, forKey: "videoDuration")
        }
    
//    private enum VideoKeys: String, CodingKey {
//        case id
//        case title
//        case description
//        case thumbnailurl
//        case duration
//    }
//
//    required init(from decoder: Decoder) throws {
//
//        //For addVideos Start ***
//        let videoContainer = try decoder.container(keyedBy: VideoKeys.self)
//
//        //Get the addVideos info
//        videoID = try? videoContainer.decode(String.self, forKey: .id)
//        videoTitle = try? videoContainer.decode(String.self, forKey: .title)
//        videoDescription = try? videoContainer.decode(String.self, forKey: .description)
//        videoThumbnailurl = try? videoContainer.decode(String.self, forKey: .thumbnailurl)
//        videoDuration = try? videoContainer.decode(String.self, forKey: .duration)
//        //For addVideos End ***
//    }
}
