//
//  LoginVC.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

//Create main user aka Master
var master: Master? = Master("", "")

class LoginVC: UIViewController {
    
    @IBOutlet weak var welcome_label: UILabel!
    @IBOutlet weak var continue_outlet: UIButton!
    @IBOutlet weak var login_outlet: StandardButton!
    @IBOutlet weak var register_outlet: StandardButton!
    
    @IBOutlet weak var email_textfield: StandardTextField!
    @IBOutlet weak var password_textfield: StandardTextField!
    
    @IBAction func forgot_button(_ sender: Any) {
        
    }
    
    func login(email: String, password: String) {
        
        // Save these in case they are correct
        master?.email = email_textfield.text!
        master?.password = password_textfield.text!
        
        Internet.database(url: baseURL + "/login_client.php", parameters: ["email": email, "password": password]) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            
            //Did the server give back an error?
            if let httpResponse = response as? HTTPURLResponse {
                
                if !(httpResponse.statusCode == 200) {
                    
                    DispatchQueue.main.async {
                        
                        switch httpResponse.statusCode{
                        case 520:
                            alert("Wrong Email", "Please check if you typed your email correctly. Otherwise please register", self)
                        case 521:
                            alert("Wrong Password", "Please check if you typed your password correctly", self)
                        default:
                            alert("Unknown Error: " + String(httpResponse.statusCode), "Please contact us under feeedbackme@gmail.com", self)
                        }
                    }
                    
                }else{
                    
                    // Check if banned
                    if (data?["BANNED"] as? String == "t"){
                        DispatchQueue.main.async {
                            
                            alert("Banned", "Sorry but you can't access converzone anymore. Contact our team.", self)
                        }
                        return
                    }
                    
                    //Login was successful
                    master?.firstname = data?["FIRSTNAME"] as? String
                    master?.lastname = data?["LASTNAME"] as? String
                    master?.uid = Int((data?["USERID"] as? String)!)
                    master?.gender = self.genderConverter(gender: (data?["GENDER"] as? String)!)
                    master?.status = NSAttributedString(string: (data?["STATUS"] as? String)!)
                    master?.interests = NSAttributedString(string: (data?["INTERESTS"] as? String)!)
                    master?.country = Country(name: (data?["COUNTRY"] as? String)!)
                    master?.deviceToken = data?["NOTIFICATIONTOKEN"] as? String
                    master?.discoverable = data?["DISCOVERABLE"] as? String == "t" ? true : false
                    master?.link_to_profile_image = data?["PROFILE_PICTURE_URL"] as? String
                    
                    let string_date = data?["BIRTHDATE"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                    master?.birthdate = dateFormatter.date(from: string_date!)
                    
                    DispatchQueue.main.async {
                        //Continue to conversations
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTBC")
                        self.present(vc!, animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    func genderConverter(gender: String) -> Gender{
        switch gender {
        case "f":
            return Gender.female
        case "m":
            return Gender.male
        case "n":
            return Gender.non_binary
        default:
            return Gender.non_binary
        }
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
        
        
        if(login_outlet.isEnabled == false) {
            
            login(email: email, password: password)
            
        }
        
        if(register_outlet.isEnabled == false){
            
            //Try register. Create Master
            master = Master(email, password)
            
            // Continue to further registration
            
            Internet.database(url: baseURL + "/check_email.php", parameters: ["email" : email]) { (data, response, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                //Did the server give back an error?
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 520{
                        DispatchQueue.main.async {
                            alert("Choose another email address or login", "It seems like we already have saved this email address in our database. Maybe try to login instead?", self)
                        }
                        return
                    }
                    
                    if !(httpResponse.statusCode == 200) {
                        
                        DispatchQueue.main.async {
                            alert("Error: " + String(httpResponse.statusCode), "", self)
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async {
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ContinentNC") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func register_button(_ sender: Any) {
        register_outlet.isEnabled = !register_outlet.isEnabled
        login_outlet.isEnabled = !login_outlet.isEnabled
        
        login_outlet.setTitleColor(Colors.darkGrey, for: .normal)
        register_outlet.setTitleColor(Colors.black, for: .normal)
    }
    
    @IBAction func login_button(_ sender: Any) {
        register_outlet.isEnabled = !register_outlet.isEnabled
        login_outlet.isEnabled = !login_outlet.isEnabled
        
        login_outlet.setTitleColor(Colors.black, for: .normal)
        register_outlet.setTitleColor(Colors.darkGrey, for: .normal)
    }
    
    
    override func viewDidLoad() {
        drawCircle()
        renderWelcomeMessage()
        
        register_outlet.isEnabled = false
        login_outlet.isEnabled = true
        
        // Let's delete all the data from the old master
        master?.conversations.removeAll()
        
        master?.changingData = .registration
    }
    
    // No need to translate this. This is meant to be in English for all
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
        
        //Calculate how big the radius should be
        let radius = view.frame.height * 0.5
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: view.frame.size.width / 3, y: continue_outlet.center.y / 2), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //It should be behind everything
        shapeLayer.zPosition = -1
        
        //change the fill color
        shapeLayer.fillColor = UIColor.white.cgColor
        
        view.layer.addSublayer(shapeLayer)
    }
    
    //Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Close keyboard when touched somewhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Disable auto rotation
    override var shouldAutorotate: Bool{
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .portrait
    }
}
