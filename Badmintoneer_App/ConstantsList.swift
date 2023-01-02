//
//  ConstantsList.swift
//  Badmintoneer_App
//
//  Created by Zhi Tham on 30/4/21.
//

import Foundation

struct ConstantsList {
    
    struct Application {
        static let bundleID = "-1029000.Badmintoneer-App"
    }
    
    struct Storyboard {
        static let mainTBVC = "MainTabBarViewController"
        static let homeVC = "HomeViewController"
        static let loginPVC = "LoginPreviewViewController"
        static let startVC = "StartScreenViewController"
        static let trainingSessVC = "TrainingSessionVC"
        static let createNewAccVC = "RegisterNewProfileVC"
    }
    
    struct FirestoreKeys {
        static let nameKey = "name"
        static let bioKey = "bio"
        static let profilePicKey = "profilepic"
        
        static let setsKey = "setsPref"
        static let swingsKey = "swingsPref"
        static let delayKey = "delayPref"
        static let recoveryKey = "recoveryPref"
        
        static let setsEarnedKey = "setsEarned"
        static let swingsEarnedKey = "swingsEarned"
    }
    
    struct Defaults {
        static let isSignedIn = "isUserSignedIn"
        static let emailDef = "emailDefault"
        static let nameDef = "nameDefault"
        static let bioDef = "bioDefault"
        static let profilePicDef = "picDefault"
        
        static let setsDef = "setsPrefDefault"
        static let swingsDef = "swingsPrefDefault"
        static let delayDef = "delayPrefDefault"
        static let recoveryDef = "recoveryPrefDefault"
        
        static let setsEarnedDef = "setsEarnedDefault"
        static let swingsEarnedDef = "swingsEarnedDefault"
        
        static let bookmarkedVideosDef = "bookmarkedVideosDefault"
    }
    
    struct DefaultValues {
        static let setsVal = "3"
        static let swingsVal = "5"
        static let delayVal = "2"
        static let recoveryVal = "2"
    }
    
    struct TempValues {
        static let bioTemp = "bioTemp"
        static let volumeTemp = "volumeTemp"
    }
    
    struct Keychains {
        static let nameKeychain = "nameKeyChain"
        static let emailKeychain = "emailKeyChain"
        static let passwordKeychain = "passwordKeyChain"
    }
    
    struct AudioFiles {
        static let back = "back"
        static let backleft = "backleft"
        static let backright = "backright"
        static let front = "front"
        static let frontleft = "frontleft"
        static let frontright = "frontright"
        static let midleft = "midleft"
        static let midright = "midright"
        static let recover = "recover"
        static let getready = "getready"
    }
    
    
}
