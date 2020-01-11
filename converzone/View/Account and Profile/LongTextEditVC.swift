//
//  LongTextEditVC.swift
//  converzone
//
//  Created by Goga Barabadze on 22.05.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

enum LongTextInput{
    case status
    case interests
}

var longTextInputFor: LongTextInput = .status

class LongTextEditVC: UIViewController {

    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        text.delegate = self
        
        if longTextInputFor == .interests {
            text.attributedText = master.interests
            self.navigationItem.title =  "Your interests"
        }else{
            text.attributedText = master.status
            self.navigationItem.title =  "Your status"
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        setUpSaveButton()
        
        if text.text.count == 0{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setUpSaveButton(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        text.becomeFirstResponder()
    }
    
    @objc private func save(){
        
        if longTextInputFor == .interests{
            master.interests = text.attributedText
        }else{
            master.status = text.attributedText
        }
        
        Navigation.pop(context: self)
    }
    
    @objc private func handleKeyboard(_ notification: Notification){
        
        
        let info = notification.userInfo!
        
        
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification{
            self.bottomConstraint.constant = keyboardFrame.size.height + 20
        }else{
            self.bottomConstraint.constant = 20
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension LongTextEditVC: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let maxLength = 1000
        
        let currentString: NSString = self.text.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        
        if newString.length == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        return newString.length <= maxLength
    }
}
