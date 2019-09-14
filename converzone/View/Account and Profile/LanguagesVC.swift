//
//  LanguagesVC.swift
//  converzone
//
//  Created by Goga Barabadze on 08.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class LanguagesVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var currentLanguages: [Language]? = nil
    var filteredLanguages: [Language]? = nil
    
    var selected_speaking_languages: [Language] = []
    var selected_learning_languages: [Language] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLanguages = world.languages
        
        selected_speaking_languages = (master?.speak_languages)!
        selected_learning_languages = (master?.learn_languages)!
        
        // Remove languages in "speaking" that are already used in "learning" and vice versa
        if addingForType == .speaking {
            currentLanguages = currentLanguages?.filter( {!selected_learning_languages.contains($0)} )
            
        }else{
            currentLanguages = currentLanguages?.filter( {!selected_speaking_languages.contains($0)} )
        }
        
        filteredLanguages = currentLanguages
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        world.sortLanguagesAlphabetically()
    }
    
    
    
}

extension LanguagesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLanguages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell")
        
        cell?.textLabel?.text = filteredLanguages![indexPath.row].name
        
        if ((selected_speaking_languages.contains(where: {$0.name == filteredLanguages![indexPath.row].name})
            || (master?.speak_languages.contains(where: {$0.name == filteredLanguages![indexPath.row].name}))!)
            
            && addingForType == .speaking)
            
            || ((selected_learning_languages.contains(where: {$0.name == filteredLanguages![indexPath.row].name})
                || (master?.learn_languages.contains(where: {$0.name == filteredLanguages![indexPath.row].name}))!)
                
                && addingForType == .learning){
            
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(addingForType == .speaking){
            
            if selected_speaking_languages.contains(where:{ $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text }){
                
                //Remove it
                selected_speaking_languages.removeAll(where: { $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text})
                master?.speak_languages.removeAll(where: { $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text})
                
            }else{
                
                //Add it
                selected_speaking_languages.append(Language(name: tableView.cellForRow(at: indexPath)!.textLabel!.text!))
            }
            
        }else{
            
            if selected_learning_languages.contains(where:{ $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text }){
                
                //Remove it
                selected_learning_languages.removeAll(where: { $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text})
                master?.learn_languages.removeAll(where: { $0.name == tableView.cellForRow(at: indexPath)!.textLabel!.text})
                
            }else{
                
                //Add it
                selected_learning_languages.append(Language(name: tableView.cellForRow(at: indexPath)!.textLabel!.text!))
            }
            
        }
        
        // Add everything to master
        if addingForType == .speaking {
            for language in selected_speaking_languages {
                master?.speak_languages.append(language)
            }
            
            //Remove duplicates
            master?.speak_languages = (Array(NSOrderedSet(array: (master?.speak_languages)!)) as? [Language])!
        }else{
            for language in selected_learning_languages {
                master?.learn_languages.append(language)
            }
            
            //Remove duplicates
            master?.learn_languages = (Array(NSOrderedSet(array: (master?.learn_languages)!)) as? [Language])!
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension LanguagesVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            filteredLanguages = currentLanguages
            tableView.reloadData()
            return
        }
        
        filteredLanguages = currentLanguages?.filter({ language -> Bool in
            return language.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
