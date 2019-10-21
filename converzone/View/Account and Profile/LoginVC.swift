//
//  LoginVC.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

var master: Master = Master(email: "", password: "")

class LoginVC: NoAutoRotateViewController {
    
    @IBOutlet weak var welcome_label: UILabel!
    @IBOutlet weak var continue_outlet: UIButton!
    @IBOutlet weak var login_outlet: ButtonForLogin!
    @IBOutlet weak var register_outlet: ButtonForLogin!
    
    @IBOutlet weak var email_textfield: TextFieldForLogin!
    @IBOutlet weak var password_textfield: TextFieldForLogin!
    
    // To show the progress of the login/registration
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    private let activityIndicatorContainer = UIView()
    
    @IBAction func forgot_button(_ sender: Any) {
        
    }
    
    @IBAction func continue_button(_ sender: Any) {
        
        guard let email = email_textfield.text          else { return }
        guard let password = password_textfield.text    else { return }
        
         if(email_textfield.text == "" || password_textfield.text == ""){
             alert(NSLocalizedString("Fill in both fields", comment: "Error title when the user doesn't fill in password and email"),
                   NSLocalizedString("Please make sure that you fill in a password and an email address", comment: "Error message when the user doesn't fill in password and email"), self)
             return
         }

         if(!Internet.isOnline()){
             alert(NSLocalizedString("Your device is offline", comment: "Error title the user gets when device is not connected to the internet"),
                   NSLocalizedString("Please make sure that your device is connected to the internet in order to proceed.", comment: "Error message the user gets when device is not connected to the internet"), self)
             return
         }

         if(!email_textfield.isValidEmail()){
             alert(NSLocalizedString("Email Address", comment: "Error title when the user enters a invalid email address"),
                   NSLocalizedString("Please make sure that you enter a valid email address.", comment: "Error message when the user enters a invalid email address"), self)
             return
         }

         if(!password_textfield.isValidPassword()){
             alert(NSLocalizedString("Password", comment: "Error title when the user enters a wrong password"),
                   NSLocalizedString("Please make sure that you enter a strong password. \n\n • 8 to 20 characters \n • Upper and Lower Case\n • One number", comment: "Error message when the user enters a wrong password"), self)
             return
         }
        
        startActivityIndicator()
        
        if(login_outlet.isEnabled == false) {
            
            
        }
        
        if(register_outlet.isEnabled == false){
            
            //Try register. Create Master
            master = Master(email: email, password: password)
            
            // Continue to further registration
            
            
        }
    }
    
    @IBAction func switch_to_register_button(_ sender: Any) {
        register_outlet.isEnabled = !register_outlet.isEnabled
        login_outlet.isEnabled = !login_outlet.isEnabled
        
        login_outlet.setTitleColor(Colors.darkGrey, for: .normal)
        register_outlet.setTitleColor(Colors.black, for: .normal)
    }
    
    @IBAction func switch_to_login_button(_ sender: Any) {
        register_outlet.isEnabled = !register_outlet.isEnabled
        login_outlet.isEnabled = !login_outlet.isEnabled
        
        login_outlet.setTitleColor(Colors.black, for: .normal)
        register_outlet.setTitleColor(Colors.darkGrey, for: .normal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawCircle()
        renderWelcomeMessage()
        setUpActivityIndicator()
        
        register_outlet.isEnabled = false
        login_outlet.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Let's delete all the data from the old master
        master.conversations.removeAll()
        master.speak_languages.removeAll()
        master.learn_languages.removeAll()
        master.changingData = .registration
    }
    
    func setUpActivityIndicator() {
        
        activityIndicator.color = Colors.black
        
        activityIndicator.center = view.center
        
        activityIndicator.hidesWhenStopped = false
        
        activityIndicatorContainer.frame = CGRect(0, 0, 80, 80)
        activityIndicatorContainer.center = self.view.center
        activityIndicatorContainer.backgroundColor = Colors.white
        activityIndicatorContainer.clipsToBounds = true
        activityIndicatorContainer.layer.cornerRadius = 10
        activityIndicatorContainer.alpha = 0.7
    }
    
    func startActivityIndicator(){
        
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicatorContainer)
        view.addSubview(activityIndicator)
    }
    
    func stopActivityIndicator(){
        
        activityIndicator.stopAnimating()
        
        activityIndicator.removeFromSuperview()
        activityIndicatorContainer.removeFromSuperview()
    }
    
    /**
     Message is displayed on the welcome screen and is meant to be in English for every user
     */
    func renderWelcomeMessage(){
        let attributedString = NSMutableAttributedString(string: "Chat with the world.")
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.blue
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 10, length: 9))
        
        welcome_label.attributedText = attributedString
    }
    
    func makeRound(button: UIButton){
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true
    }
    
    func drawCircle(){
        
        let radius = view.frame.height * 0.5
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.size.width / 3, y: continue_outlet.center.y / 2), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.zPosition = -1
        
        shapeLayer.fillColor = UIColor.white.cgColor
        
        view.layer.addSublayer(shapeLayer)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Close keyboard when touched somewhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
