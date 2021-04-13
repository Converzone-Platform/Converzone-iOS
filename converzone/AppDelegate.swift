//
//  AppDelegate.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase
import FirebaseMessaging
import os

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
    
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        StoreReview.incrementAppOpenedCount()
        
        //Internet.updateLastActive()
        
        return true
    }
    
    // MARK: Messaging
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      let dataDict:[String: String] = ["token" : fcmToken]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
      master.device_token = fcmToken
      Internet.fcm_token = fcmToken
      Internet.upload(token: fcmToken)
    }
    
    // MARK: - Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        #warning("Open chat when user clicks on notification")
        
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        
        guard let sender_id = notification.request.content.userInfo["sender_id"] as? String else {
            os_log("Could not get sender_id from notification")
            return
        }
        
        // If we are already in the chat there is no need to show a push notification
        if sender_id == chatOf.uid {
            return
        }
        
        for user in master.conversations {
            if user.uid == sender_id && user.muted {
                return
            }
        }
        
        completionHandler([.alert, .badge, .sound])
    }
    
    // MARK: Account
    func applicationWillTerminate(_ application: UIApplication) {
        if Navigation.didNotFinishRegistration() {
            Internet.signOut()
        }
        
        Internet.stoppedTyping(uid: chatOf.uid)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if Navigation.didNotFinishRegistration() {
            Internet.signOut()
        }
        
        Internet.stoppedTyping(uid: chatOf.uid)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "converzone")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
