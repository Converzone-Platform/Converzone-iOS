//
//  StoreReview.swift
//  converzone
//
//  Created by Goga Barabadze on 12.02.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import StoreKit

struct StoreReview {
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = UserDefaults.standard.value(forKey: "AppOpenedCount") as? Int else {
            UserDefaults.standard.set(1, forKey: "AppOpenedCount")
            return
        }
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: "AppOpenedCount")
    }
    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = UserDefaults.standard.value(forKey: "AppOpenedCount") as? Int else {
            UserDefaults.standard.set(1, forKey: "AppOpenedCount")
            return
        }
        
        switch appOpenCount {
        case 10,50:
            StoreReview().requestReview()
        case _ where appOpenCount%100 == 0 :
            StoreReview().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    
    fileprivate func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
