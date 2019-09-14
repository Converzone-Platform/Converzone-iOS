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
    
    private var didSetImage: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profile_image.addGestureRecognizer(tapGesture)
        profile_image.isUserInteractionEnabled = true
        
        //Add a done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        self.navigationItem.rightBarButtonItem = doneButton
        
        if master?.changingData == .editing && Internet.isOnline(){
            
            master?.getImage(with: master!.link_to_profile_image!, completion: { (image) in
                self.profile_image.image = image
            })
            
            profile_image.layer.masksToBounds = true
            profile_image.layer.cornerRadius = profile_image.frame.width / 2
        }
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
        
        view.removeGestureRecognizer(tap)
    }
    
    func checkInputOfUser(_ firstname: String, _ lastname: String, _ gender: String, _ date: String, _ interests: String, _ status: String) -> Bool{
        // Check if everything is fine with the inputs of the user
        
        // 1. Did the user pick an image?
        if profile_image.image.hashValue == UIImage(named: "user").hashValue {
            alert("Profile Image", "Please choose a profile image", self)
            return false
        }
        
        // 2. No emojis in the first and last name
        if firstname.containsEmoji{
            alert("Firstname", "Please make sure you don't use emojis in your firstname", self)
            return false
        }else{
            master?.firstname = firstname.trimmingCharacters(in: .whitespaces).capitalizingFirstLetter()
        }
        
        if lastname.containsEmoji{
            alert("Lastname", "Please make sure you don't use emojis in your lastname", self)
            return false
        }else{
            master?.lastname = lastname.trimmingCharacters(in: .whitespaces).capitalizingFirstLetter()
        }
        
        // 3. Did the user input a gender outside of our defined ones?
        var found = false
        for currentGender in Gender.allCases{
            if gender == currentGender.toString(){
                found = true
            }
        }
        
        if found == false{
            alert("Gender", "Please make sure you enter one of the predefined genders", self)
            return false
        }else{
            master?.gender = genderConveter(gender: gender.trimmingCharacters(in: .whitespaces))
        }
        
        // 4. Can the date be correct?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let newDate = dateFormatter.date(from: date.trimmingCharacters(in: .whitespaces)){
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .timeZone, .calendar], from: newDate)
            
            // Let's check if the components can be correct practically
            if components.year! > 3000{
                alert("Wow", "Are you from the future?", self)
                return false
            }else{
                
                master?.birthdate = newDate
            }
            
        }else{
            alert("Birthdate", "Please enter a valid date", self)
            return false
        }
        
        return true
    }
    
    @objc func donePressed(){
        
        // Get inputs
        
        var firstname = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! NormalInputCell).input!.text
        firstname = firstname?.trimmingCharacters(in: .whitespacesAndNewlines)
        if firstname == "" {
            alert("Firstname", "Please tell us your first name", self)
            return
        }
        
        var lastname = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! NormalInputCell).input!.text
        lastname = lastname?.trimmingCharacters(in: .whitespacesAndNewlines)
        if lastname == "" {
            alert("Lastname", "Please tell us your last name", self)
            return
        }
        
        var gender = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputGenderCell).gender.text
        gender = gender?.trimmingCharacters(in: .whitespacesAndNewlines)
        if gender == "" {
            alert("Gender", "Please tell us your gender", self)
            return
        }
        
        var date = (tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell).date.text
        date = date?.trimmingCharacters(in: .whitespacesAndNewlines)
        if date == "" {
            alert("Birthdate", "Please tell us your birthdate", self)
            return
        }
        
        if master?.interests == nil || (master?.interests?.string.isEmpty)! {
            alert("Interests", "Please tell us about your intersts", self)
            return
        }
        
        if master!.status == nil || (master?.status?.string.isEmpty)! {
            alert("Status", "Please tell us what you want your status to be", self)
            return
        }
        
        if checkInputOfUser(firstname!, lastname!, gender!, date!, (master?.interests!.string)!, (master?.status!.string)!) == false{
            return
        }
        
        master?.discoverable = (tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! BooleanInputCell).discoverable.isOn
        
        // Give the server all information about the master and get an (u)id back
        // Let's create a user
        //2019-06-20 11:23:10:721 +02:00 ... "yyyy-MM-dd HH:mm:ss:SSS XXXXX"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var one_letter_gender = ""
        
        switch master?.gender?.toString() {
        case "female":
            one_letter_gender = "f"
        case "male":
            one_letter_gender = "m"
        case "non binary":
            one_letter_gender = "n"
        default:
            one_letter_gender = "f"
        }
        
        let data: [String: Any] = [
            "FIRSTNAME": master!.firstname!,
            "LASTNAME": master!.lastname!,
            "GENDER": one_letter_gender,
            "FIRSTJOIN": formatter.string(from: Date()),
            "BIRTHDATE": formatter.string(from: master!.birthdate!),
            "INTERESTS": master!.interests!,
            "STATUS": master!.status!,
            "COUNTRY": master!.country!.name!,
            
            // Everyone is a pro in the first version
            "PRO": "t",
            "DISCOVERABLE": master!.discoverable ? "t" : "f",
            "NOTIFICATIONTOKEN": master?.deviceToken ?? "TEMP_TOKEN",
            "EMAIL": master!.email,
            "PASSWORD": master!.password,
        ]

        Internet.database(url: Internet.baseURL + "/register_client.php", parameters: data) { (data_back, response, error) in

            
            master!.uid = Int((data_back?["USERID"] as? String)!)

            if master?.changingData == .registration {
                
                // Send languages
                Internet.database(url: Internet.baseURL + "/deleteAllLanguages.php", parameters: ["USERID" : master!.uid!]) { (backdata, response, error) in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if httpResponse.statusCode != 200{
                            print(httpResponse)
                        }
                        
                    }
                    
                }
                for language in master!.speak_languages{
                    
                    let language_data: [String : Any] = [
                        "USERID": master!.uid!,
                        "PROFICIENCY": "s",
                        "LANGUAGE": language.name
                    ]
                    
                    Internet.database(url: Internet.baseURL + "/addLanguages.php", parameters: language_data) { (backdata, response, error) in
                        
                        if error != nil{
                            print(error!.localizedDescription)
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            if httpResponse.statusCode != 200{
                                print(httpResponse)
                            }
                            
                        }
                        
                    }
                }
                for language in master!.learn_languages{
                    
                    let language_data: [String : Any] = [
                        "USERID": master!.uid!,
                        "PROFICIENCY": "l",
                        "LANGUAGE": language.name
                    ]
                    
                    Internet.database(url: Internet.baseURL + "/addLanguages.php", parameters: language_data) { (backdata, response, error) in
                        
                        if error != nil{
                            print(error!.localizedDescription)
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            if httpResponse.statusCode != 200{
                                print(httpResponse)
                            }
                            
                        }
                        
                        // Upload Image
                        self.uploadProfileImage(profileImage: self.profile_image.image!)
                        
                    }
                }
            }
        }
        
        if master?.changingData == .registration {
            
            // Go to welcome screen
            Navigation.present(controller: "WelcomeVC", context: self)
        }else{
            Navigation.pop(context: self)
        }
    }
    
    func uploadProfileImage(profileImage: UIImage){
        
        
    }
    
    
    
    @objc func pickDate (datePicker: UIDatePicker){
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: Locale.current.languageCode!) as Locale
        formatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputDateCell
        cell.date.text = formatter.string(from: datePicker.date)
        
        master?.birthdate = datePicker.date
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
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
        return Gender.allCases.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0{
            return "Choose your gender"
        }
        
        return Gender.allCases[row-1].toString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputGenderCell
        
        if row == 0 {
            
            pickerView.selectRow(1, inComponent: component, animated: true)
            cell.gender.text = Gender.allCases[0].toString()
        }else{
            cell.gender.text = Gender.allCases[row-1].toString()
        }
        
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
            
            Navigation.push(viewController: "LongTextEditVC", context: self)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            cell.input?.placeholder = "First name"
            
            cell.input?.addTarget(self, action: #selector(firstNameTextFieldChanged), for: .editingChanged)
            
            if !(master?.firstname?.isEmpty ?? false) {
                cell.input!.text = master?.firstname
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            cell.input?.placeholder = "Last name"
            
            cell.input?.addTarget(self, action: #selector(lastNameTextFieldChanged), for: .editingChanged)
            
            if !(master?.lastname?.isEmpty ?? false)  {
                cell.input!.text = master?.lastname
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputGenderCell") as! InputGenderCell
            
            cell.title?.text = titlesOfCells[getIndexOfTitles(indexPath: indexPath)]
            
            cell.gender.placeholder = "Gender"
            
            let picker = UIPickerView()
            picker.delegate = self
            
            if master?.gender != nil{
                cell.gender.text = master?.gender?.toString()
            }
            
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
            
            if master?.birthdate != nil{
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let string = dateFormatter.string(from: master!.birthdate!)
                
                cell.date.text = string
            }
            
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
            
            if master?.discoverable != nil{
                cell.discoverable.isOn = master!.discoverable
            }
            
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
    
    @objc func firstNameTextFieldChanged(){
        master?.firstname = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel!.text
    }
    
    @objc func lastNameTextFieldChanged(){
        master?.lastname = tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.textLabel!.text
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
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { action in
            
            self.getImageFromLibrary()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
            self.getImageFromCamera()
            
        }))
        
        alert.addAction ( UIAlertAction(title: "Cancel", style: .cancel, handler: { action in }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage]
        
        profile_image.image = cropToBounds(image: image as! UIImage, width: 500, height: 500)
        profile_image.layer.cornerRadius = profile_image.layer.frame.width / 2
        profile_image.layer.masksToBounds = true
        
        // Delete the old cached image
        master!.cache.removeAllObjects()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
    
    let cgimage = image.cgImage!
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
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
}
