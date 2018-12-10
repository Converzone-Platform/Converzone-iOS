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
    
    var checked_speaking: [Bool] = []
    var checked_learning: [Bool] = []
    
    override func viewDidLoad() {
        
        currentLanguages = world.languages
        
        //MARK: - TODO Filter already used languages
        
        filteredLanguages = currentLanguages
        
        //We need that for later saving which cell has been marked
        checked_speaking = Array(repeating: false, count: (currentLanguages?.count)!)
        checked_learning = Array(repeating: false, count: (currentLanguages?.count)!)
    }
}

extension LanguagesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLanguages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell")
        
        cell?.textLabel?.text = filteredLanguages![indexPath.row].name
        
        if(checked_speaking[indexPath.row] == true && addingForType == .speaking) || checked_learning[indexPath.row] == true && addingForType == .learning{
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(addingForType == .speaking){
            checked_speaking[indexPath.row] = !checked_speaking[indexPath.row]
        }else{
            checked_learning[indexPath.row] = !checked_learning[indexPath.row]
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if(addingForType == .speaking){
            if(checked_speaking[indexPath.row] == true){
                master?.speak_languages?.append(Language(name: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!))
            }else{
                master?.speak_languages?.removeAll(where: {$0.name == tableView.cellForRow(at: indexPath)?.textLabel?.text})
            }
            
        }else{
            
            if(checked_learning[indexPath.row] == true){
                master?.learn_languages?.append(Language(name: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!))
            }else{
                master?.learn_languages?.removeAll(where: {$0.name == tableView.cellForRow(at: indexPath)?.textLabel?.text})
            }
            
            
        }
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
            return language.name!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
}
