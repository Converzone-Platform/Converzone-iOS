//
//  EditProfileVC.swift
//  converzone
//
//  Created by Goga Barabadze on 11.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController{
    
    @IBOutlet weak var profile_image: UIImageView!
    
    var titlesOfCells = ["First name", "Last name", "Gender", "Birthdate", "Interests", "Status", "Discoverable"]
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profile_image.addGestureRecognizer(tapGesture)
        profile_image.isUserInteractionEnabled = true
        
        //Add a done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func endEditing() {
        view.endEditing(true)
        
        view.removeGestureRecognizer(tap)
    }
    
    @objc func donePressed(){
        print("Save everything and send to server!")
    }
    
    @objc func pickDate (datePicker: UIDatePicker){
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/YYYY"
        formatter.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
        
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell
        cell.date.text = formatter.string(from: datePicker.date)
        
    }
    
}

extension EditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return Gender.allCases[row].toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputGenderCell
        cell.gender.text = Gender.allCases[row].toString()
    }
}

extension EditProfileVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 3) { return 1 }
        
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 4 || tableView.globalIndexPath(for: indexPath as NSIndexPath) == 5 {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "LongTextEditVC")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
    func getIndexOfTitles( indexPath: IndexPath ) -> Int{
        
        switch indexPath.section {
        case 0:
            if ( indexPath.row == 0) { return 0 }
            
            return 1
        case 1:
            if ( indexPath.row == 0) { return 2 }
            
            return 3
        case 2:
            if ( indexPath.row == 0) { return 4 }
            return 5
        case 3:
            return 6
        default:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            return cell
            
        case 1:
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InputGenderCell") as! InputGenderCell
                
                cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
                
                let picker = UIPickerView()
                picker.delegate = self
                
                cell.gender.inputView = picker
                
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InputDateCell") as! InputDateCell
                
                cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
                
                // Setup date picker
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                datePicker.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
                
                let calendar = Calendar(identifier: .gregorian)
                var comps = DateComponents()
                comps.year = 0
                let maxDate = calendar.date(byAdding: comps, to: Date())
                comps.year = -150
                let minDate = calendar.date(byAdding: comps, to: Date())
                
                datePicker.minimumDate = minDate
                datePicker.maximumDate = maxDate
                
                cell.date.inputView = datePicker
                
                datePicker.addTarget(self, action: #selector(pickDate(datePicker:)), for: .valueChanged)
                
                return cell
                
            }
            
            
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputLongTextCell") as! InputLongTextCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanInputCell") as! BooleanInputCell
            
            cell.discoverable.isOn = true
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            return cell
        
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary;
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    func getImageFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.allowsEditing = true
            image.cameraCaptureMode = .photo
            self.present(image, animated: true, completion: nil)
        }
    }
    
    @objc func imageTapped(){
        
        let alert = UIAlertController(title: "", message: "What do you want to do?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose a picture from your library", style: .default, handler: { action in
            
            self.getImageFromLibrary()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Take a picture now", style: .default, handler: { action in
            
            self.getImageFromCamera()
            
        }))
        
        alert.addAction ( UIAlertAction(title: "Cancel", style: .cancel, handler: { action in }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage]
        
        profile_image.image = image as? UIImage
        profile_image.layer.cornerRadius = profile_image.layer.frame.width / 2
        profile_image.layer.masksToBounds = true
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
