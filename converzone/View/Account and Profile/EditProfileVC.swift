//
//  EditProfileVC.swift
//  converzone
//
//  Created by Goga Barabadze on 11.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import os

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var profile_image: UIImageView!
    
    var titlesOfCells = ["First name",
                         "Last name",
                         "Gender",
                         "Birthdate",
                         "Interests",
                         "Status",
                         "Discoverable"]
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
    
    private var didSetImage: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profile_image.addGestureRecognizer(tapGesture)
        profile_image.isUserInteractionEnabled = true
        
        var title_of_button = "Done"
        
        if master.editingMode == .editing{
            title_of_button = "Save"
        }
        
        let doneButton = UIBarButtonItem(title: title_of_button, style: .done, target: self, action: #selector(donePressed))
        self.navigationItem.rightBarButtonItem = doneButton
        
        if master.editingMode == .editing {
            
            Internet.setImage(withURL: master.link_to_profile_image, imageView: self.profile_image)
            
            profile_image.roundCorners(radius: profile_image.frame.width / 2, masksToBounds: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // We need to save the first and lastname from the input fields
        guard let firstname = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NormalInputCell)?.input?.text else{
            return
        }
        
        guard let lastname = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NormalInputCell)?.input?.text else{
            return
        }
        
        master.firstname = firstname
        master.lastname = lastname
        
        
    }
    
    @objc func endEditing() {
        view.endEditing(true)
        view.removeGestureRecognizer(tap)
    }
    
    private func checkInputOfUser(_ firstname: String, _ lastname: String, _ gender: String, _ date: String, _ interests: String, _ status: String) -> Bool{
        // Check if everything is fine with the inputs of the user
        
        // 1. Did the user pick an image?
        if #available(iOS 13.0, *) {
            if profile_image.image.hashValue == UIImage(systemName: "person.circle").hashValue {
                Alert.alert(title: "Profile Image", message: "Please choose a profile image")
                return false
            }
        } else {
            if profile_image.image.hashValue == UIImage(named: "user").hashValue {
                Alert.alert(title: "Profile Image", message: "Please choose a profile image")
                return false
            }
        }
        
        // 2. No emojis in the first and last name
        if firstname.contains_emoji{
            Alert.alert(title: "Firstname", message: "Please make sure you don't use emojis in your firstname")
            return false
        }else{
            master.firstname = firstname.trimmingCharacters(in: .whitespaces).capitalizingFirstLetter()
        }
        
        if lastname.contains_emoji{
            Alert.alert(title: "Lastname", message: "Please make sure you don't use emojis in your lastname")
            return false
        }else{
            master.lastname = lastname.trimmingCharacters(in: .whitespaces).capitalizingFirstLetter()
        }
        
        // 3. Did the user input a gender outside of our defined ones?
        var found = false
        for currentGender in Gender.allCases{
            if gender == currentGender.toString(){
                found = true
            }
        }
        
        if found == false{
            master.gender = Gender.toGender(gender: "")
        }else{
            master.gender = Gender.toGender(gender: gender.trimmingCharacters(in: .whitespaces))
        }
        
        // 4. Can the date be correct?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let newDate = dateFormatter.date(from: date.trimmingCharacters(in: .whitespaces)){
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .timeZone, .calendar], from: newDate)
            
            // Let's check if the components can be correct practically
            
            if components.year! > 3000{
                Alert.alert(title: "Wow", message: "Are you from the future? Write me an email. I have some questions :)")
                return false
            }
            
            master.birthdate = newDate
            
        }
        
        guard profile_image.image != nil else {
            Alert.alert(title: "Could not upload image", message: "Please choose an image and try again.")
            return false
        }
        
        return true
    }
    
    @objc private func donePressed(){
        
        let firstname = master.firstname.trimmingCharacters(in: .whitespacesAndNewlines)
        if firstname.isEmpty {
            Alert.alert(title: "Firstname", message: "Please tell us your first name")
            
            return
        }
        
        let lastname = master.lastname.trimmingCharacters(in: .whitespacesAndNewlines)
        if lastname.isEmpty {
            Alert.alert(title: "Lastname", message: "Please tell us your last name")
            return
        }
        
        var gender = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputGenderCell).gender.text
        gender = gender?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var date = (tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell).date.text
        date = date?.trimmingCharacters(in: .whitespacesAndNewlines)
        if date == "" {
            
            master.birthdate = nil
        }
        
        if master.interests.string.isEmpty {
            Alert.alert(title: "Interests", message: "Please tell us about your intersts")
            return
        }
        
        if master.status.string.isEmpty {
            Alert.alert(title: "Status", message: "Please tell us what you want your status to be")
            return
        }
        
        
        if checkInputOfUser(firstname, lastname, gender!, date!, master.interests.string, master.status.string) == false{
            return
        }
        
        master.discoverable = (tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! BooleanInputCell).boolean.isOn
        
        if master.editingMode == .registration {
            
            // Go to welcome screen
            performSegue(withIdentifier: "goToWelcomeScreenSegue", sender: nil)
            
        }else{
            navigationController?.popViewController(animated: true)
        }
        
        Internet.upload()
        
        if master.speak_languages.isEmpty == false {
            Internet.uploadLanguages()
        }
        
        guard let image = profile_image.image else {
            Alert.alert(title: "Could not upload image", message: "Please choose an image and try again.")
            return
        }
        
        Internet.upload(image: image)
    }
    
    @objc private func pickDate (datePicker: UIDatePicker){
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        
        
        formatter.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
        
        formatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        
        
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell
        cell.date.text = formatter.string(from: datePicker.date)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 1:
            return "These two fields are optional. We suggest entering them though. That way you (and other people) have access to a whole bunch of fancy filtering features."
        case 3:
            return "Disable this if you don't want new people to text you. This set on \"off\" will make sure you are not visible for others in the discover tab"
        default:
            return ""
        }
        
    }
    
}

extension EditProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count - 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return ""
        }
        
        return Gender.allCases[row].toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? InputGenderCell else {
            os_log("Could not load InputGenderCell class")
            return
        }
        
        if row == 0{
            cell.gender.text = ""
        }else{
            cell.gender.text = Gender.allCases[row].toString()
            master.gender = Gender.allCases[row]
        }
    }
    
    
}

extension EditProfileVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 3 { return 1 }
        
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
            
            Navigation.push(viewController: "LongTextEditVC", context: self)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell.input?.placeholder = "First name"
            cell.input?.textContentType = .givenName
            
            cell.input?.addTarget(self, action: #selector(firstNameTextFieldChanged), for: .editingChanged)
            
            if !master.firstname.isEmpty {
                
                cell.input!.text = master.firstname
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell.input?.placeholder = "Last name"
            cell.input?.textContentType = .familyName
            
            cell.input?.addTarget(self, action: #selector(lastNameTextFieldChanged), for: .editingChanged)
            
            if !master.lastname.isEmpty  {
                
                cell.input!.text = master.lastname
            }
            
            return cell
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputGenderCell") as! InputGenderCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            cell.gender.placeholder = "Gender"
            
            let picker = UIPickerView()
            picker.delegate = self
            
            if master.gender != nil {
                cell.gender.text = master.gender?.toString()
            }
            
            cell.gender.inputView = picker
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputDateCell") as! InputDateCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            // Setup date picker
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            
            datePicker.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
            
            let calendar = Calendar(identifier: .gregorian)
            var comps = DateComponents()
            comps.year = 0
            let maxDate = calendar.date(byAdding: comps, to: Date())
            comps.year = -130
            let minDate = calendar.date(byAdding: comps, to: Date())
            
            datePicker.minimumDate = minDate
            datePicker.maximumDate = maxDate
            
            // Minus 12 years
            datePicker.date = Date() - 60 * 60 * 24 * 365 * 12
            
            cell.date.inputView = datePicker
            
            datePicker.addTarget(self, action: #selector(pickDate(datePicker:)), for: .valueChanged)
            
            guard let birthdate = master.birthdate else {
                return cell
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            cell.date.text = dateFormatter.string(from: birthdate)
            
            return cell
        case 4:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputLongTextCell") as! InputLongTextCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            if master.interests.string == "" {
                cell.input.text = "Your interests"
                cell.input.textColor = Colors.grey
            }else{
                cell.input.text = master.interests.string
                cell.input.textColor = Colors.black
            }
            
            return cell
        case 5:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputLongTextCell") as! InputLongTextCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            if master.status.string == "" {
                cell.input.text = "What keeps you up at night?"
                cell.input.textColor = Colors.grey
            }else{
                cell.input.text = master.status.string
                cell.input.textColor = Colors.black
            }
            
            return cell
        case 6:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanInputCell") as! BooleanInputCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            cell.boolean.isOn = master.discoverable
            
            cell.boolean.isEnabled = false
            
            return cell
        default:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @objc func firstNameTextFieldChanged(){
        
        guard let firstname = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NormalInputCell).input?.text else {
            return
        }
        master.firstname = firstname
    }
    
    @objc func lastNameTextFieldChanged(){
        
        guard let lastname = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! NormalInputCell).input?.text else {
            return
        }
        
        master.lastname = lastname
    }
    
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func getImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary;
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    private func getImageFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.allowsEditing = true
            image.cameraCaptureMode = .photo
            self.present(image, animated: true, completion: nil)
        }
    }
    
    @objc private func imageTapped(){
        
        let actions = [
        
            UIAlertAction(title: "Camera", style: .default, handler: { action in
                
                self.getImageFromCamera()
                
            }),
            
            UIAlertAction(title: "Library", style: .default, handler: { action in
                
                self.getImageFromLibrary()
                
            }),
            
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        ]
        
        Alert.alert(title: nil, message: nil, actions: actions)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        profile_image.image = cropToBounds(image: image, width: 500, height: 500)
        
        profile_image.roundCorners(radius: profile_image.layer.frame.width / 2, masksToBounds: true)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

private func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
    
    guard let cgimage = image.cgImage else {
        os_log("Could not extract image")
        return image
    }
    
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    guard let imageRef = cgimage.cropping(to: rect) else {
        os_log("Could not crop image")
        return image
    }
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}
