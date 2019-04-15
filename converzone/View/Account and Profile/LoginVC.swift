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
    
    //Design/Label
    @IBOutlet weak var welcome_label: UILabel!
    @IBOutlet weak var continue_outlet: UIButton!
    @IBOutlet weak var login_outlet: StandardButton!
    @IBOutlet weak var register_outlet: StandardButton!
    
    //TextFields
    @IBOutlet weak var email_textfield: StandardTextField!
    @IBOutlet weak var password_textfield: StandardTextField!
    
    //Buttons
    @IBAction func forgot_button(_ sender: Any) {
        
    }
    
    func login(email: String, password: String) {
        
        // Save these in case they are correct
        master?.email = email_textfield.text!
        master?.password = password_textfield.text!
        
        Internet.database(url: baseURL + "login_client.php", parameters: ["email": email, "password": password]) { (data, response, error) in
            
            if error != nil {
                print(error!)
            }
            
            //Did the server give back an error?
            if let httpResponse = response as? HTTPURLResponse {
                
                if !(httpResponse.statusCode == 200) {
                    
                    DispatchQueue.main.async {
                        self.alert("Error", String(httpResponse.statusCode))
                    }
                    
                    // hash of "1": $2y$10$vDEhAhrg0KDcLj7tjEMFE.oU4Ul8ib98VlZlz8fH9fIFCZkTTMbua
                    
//                INSERT INTO USERS (USERID, PASSWORD, FIRSTNAME, LASTNAME, GENDER, FIRSTJOIN, BIRTHDAY, , EMAIL, INTRESTS, BIO, COUNTRYID, BLOCKEDBYTHESYSTEM)
//
//                    VALUES (1, '$2y$10$vDEhAhrg0KDcLj7tjEMFE.oU4Ul8ib98VlZlz8fH9fIFCZkTTMbua', 'Goga', 'Barabadze',TO_DATE('14/12/2015', 'DD/MM/YYYY'), '1');
                    
                
                    
                    //UPDATE USERS SET PASSWORD="$2y$10$vDEhAhrg0KDcLj7tjEMFE.oU4Ul8ib98VlZlz8fH9fIFCZkTTMbua" FROM USERS WHERE EMAIL="tmail@skl";
                    
                }else{
                    //Login was successful
                    print(data)
                    master?.firstname = data?["FIRSTNAME"] as? String
                    master?.lastname = data?["LASTNAME"] as? String
                    master?.uid = data?["USERID"] as? Int
//                    master?.gender =
                }
            }
        }
    }
    
    @IBAction func continue_button(_ sender: Any) {
        
        guard let email = email_textfield.text          else { return }
        guard let password = password_textfield.text    else { return }
        
//        if(email_textfield.text == "" || password_textfield.text == ""){
//         alert(NSLocalizedString("Fill in both fields", comment: "Error title when the user doesn't fill in password and email"),
//         NSLocalizedString("Please make sure that you fill in a password and an email address", comment: "Error message when the user doesn't fill in password and email"))
//         return
//         }
//
//         if(!Internet.isOnline()){
//         alert(NSLocalizedString("Your device is offline", comment: "Error title the user gets when device is not connected to the internet"),
//         NSLocalizedString("Please make sure that your device is connected to the internet in order to proceed.", comment: "Error message the user gets when device is not connected to the internet"))
//         return
//         }
//
//         if(!email_textfield.isValidEmail()){
//         alert(NSLocalizedString("Email Address", comment: "Error title when the user enters a invalid email address"),
//         NSLocalizedString("Please make sure that you enter a valid email address.", comment: "Error message when the user enters a invalid email address"))
//         return
//         }
//
//         if(!password_textfield.isValidPassword()){
//         alert(NSLocalizedString("Password", comment: "Error title when the user enters a wrong password"),
//         NSLocalizedString("Please make sure that you enter a strong password. \n\n • 8 to 20 characters \n • Upper and Lower Case\n • One number", comment: "Error message when the user enters a wrong password"))
//         return
//         }
        
        
        if(login_outlet.isEnabled == false) {
            
            login(email: email, password: password)
            
        }
        
        if(register_outlet.isEnabled == false){
            
            //Try register. Create Master
            master = Master(email, password)
            
            // Continue to further registration
            
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
    }
    
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
    
    func alert(_ title: String, _ message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("")
                
            case .cancel:
                print("")
                
            case .destructive:
                print("")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
