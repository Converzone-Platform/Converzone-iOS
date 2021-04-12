//
//  PhoneVerification.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import FirebaseAuth
import os
import Kingfisher
import SwiftAlert

extension Internet {
    
    /// Requests a silent push notification to the device and afterwards it send a SMS to the phone number
    /// - Parameter phoneNumber: The phone number to which the SMS is sent
    static func verify(phoneNumber: String, closure: @escaping (Bool) -> Void){
    
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            
          if error != nil {
            
            Alert.alert(title: "Error while verifying", message: error?.localizedDescription)
            
            closure(false)
            
            return
          }
            
          UserDefaults.standard.setValue(verificationID, forKey: "verificationID")
            
            closure(true)
        }
        
    }
    
    
    static func signIn(with verificationCode: String, closure: @escaping (Error?) -> Void) {
        
        guard let verification_id = UserDefaults.standard.string(forKey: "verificationID") else {
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification_id, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if error != nil {
            
            closure(error)
            
            return
          }
          
            closure(nil)
            
            guard let uid = Auth.auth().currentUser?.uid else {
                os_log("Firebase's current user isn't initialized")
                return
            }
            
            master.uid = uid
            
            UserDefaults.standard.removeObject(forKey: "verificationID")
        }
        
    }
    
    /// User was logged out (or logged in)
    private static func listenForDidChangeAuthState(){
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user == nil {
                
                Internet.signOut()
                
            }
            
        }
        
    }
    
    static func signOut(){
        
        do{
            try Auth.auth().signOut()
            
            discover_users.removeAll()
            Internet.removeListeners()
            
            Internet.removeToken()
            
            master = Master()
            
            UserDefaults.standard.removeObject(forKey: "DidFinishRegistration")
            
        }catch{
            Alert.alert(title: "Signing out...", message: "An unknown error occurred")
        }
    }
    
    static func updateLastActive(){
        
        self.database_reference.child("users").child(master.uid).child("last_active").setValue(Date.dateAsTimeIntervalSince1970WithoutDots(date: Date()))
        
    }
}
