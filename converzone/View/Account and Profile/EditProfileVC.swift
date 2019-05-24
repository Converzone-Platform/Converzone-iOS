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
    
    var titlesOfCells = ["First name",
                         "Last name",
                         "Gender",
                         "Birthdate",
                         "Interests",
                         "Status",
                         "Discoverable"]
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
        
        view.removeGestureRecognizer(tap)
    }
    
    @objc func donePressed(){
        
        // Give the server all information about the master and get an (u)id back
     
        Internet.database(url: baseURL + "/register_user.php", parameters: ["":""]) { (data, response, error) in
            
            
            
        }
    }
    
    @objc func pickDate (datePicker: UIDatePicker){
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/YYYY"
        formatter.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
        
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell
        cell.date.text = formatter.string(from: datePicker.date)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension EditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0{
            return "Choose your gender"
        }
        
        return Gender.allCases[row-1].toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            
            pickerView.selectRow(1, inComponent: component, animated: true)
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputGenderCell
        cell.gender.text = Gender.allCases[row-1].toString()
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
            
            if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 4{
                longTextInputFor = .interests
            }else{
                longTextInputFor = .status
            }
            
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
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            cell.input?.placeholder = "First name"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            cell.input?.placeholder = "Last name"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputGenderCell") as! InputGenderCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            cell.gender.placeholder = "Gender"
            
            let picker = UIPickerView()
            picker.delegate = self
            
            cell.gender.inputView = picker
            
            return cell
        case 3:
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
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputLongTextCell") as! InputLongTextCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            if master?.interests?.string == nil {
                cell.input.text = "Your interests"
                cell.input.textColor = Colors.grey
            }else{
                cell.input.text = master?.interests?.string
                cell.input.textColor = Colors.black
            }
            
            return cell
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputLongTextCell") as! InputLongTextCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            if master?.status?.string == nil {
                cell.input.text = "Tell the world something"
                cell.input.textColor = Colors.grey
            }else{
                cell.input.text = master?.status?.string
                cell.input.textColor = Colors.black
            }
            
            return cell
        case 6:
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
