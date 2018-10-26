//
//  LoginVC.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    //MARK: Variables
    var type = "login"{
        didSet{
            print(type)
        }
    }

    //MARK: Design
    @IBOutlet weak var box_view: UIView!
    
    //MARK: Outlet Declarations
    @IBOutlet weak var continue_button: UIButton!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var register_button: UIButton!
    
    
    //MARK: Textfields
    @IBOutlet weak var email_textfield: UITextField!
    @IBOutlet weak var password_textfield: UITextField!
    
    //MARK: Labels
    @IBOutlet weak var error_message: UILabel!
    
    //MARK: Buttons
    @IBAction func login(_ sender: Any) {
        //If login is not already selected than switch colors
        //MARK: TODO: Save this information somewhere
        
        
        
    }
    
    @IBAction func register(_ sender: Any) {
        //If register is not already selected than switch colors
        //MARK: TODO: Save this information somewhere
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    //MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Add Gestures
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillLayoutSubviews() {
        setupEverything()
    }
    
    //MARK: Setup Functions
    func setupEverything(){
        setupBoxView()
        setupContinueButton()
        setupEmailTextField()
        setupPasswordTextField()
        setupErrorMessageLabel()
    }
    
    func setupBoxView(){
        roundCorners(layer: box_view.layer, cornerRadius: 10)
    }
    
    func setupContinueButton(){
        roundCorners(layer: continue_button.layer, cornerRadius: continue_button.frame.size.height/2)
    }
    
    func setupEmailTextField(){
        roundCorners(layer: email_textfield.layer, cornerRadius: 10)
        
        email_textfield.borderStyle = UITextField.BorderStyle.none
    }
    
    func setupPasswordTextField(){
        roundCorners(layer: password_textfield.layer, cornerRadius: 10)
        password_textfield.borderStyle = UITextField.BorderStyle.none
    }
    
    func setupErrorMessageLabel(){
        //Remove the text of the storyboard
        error_message.text = nil
    }
    
    //MARK: Design
    func roundCorners(layer: CALayer, cornerRadius: CGFloat){
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    //MARK: Keyboard
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

