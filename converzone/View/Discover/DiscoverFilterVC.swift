//
//  DiscoverFilterVC.swift
//  converzone
//
//  Created by Goga Barabadze on 28.12.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import RangeSeekSlider

class DiscoverFilterVC: UIViewController {
    
    @objc func genderFilterChanged(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0: master.discover_gender_filter = .any
        case 1: master.discover_gender_filter = .female
        case 2: master.discover_gender_filter = .male
        case 3: master.discover_gender_filter = .non_binary
        default: master.discover_gender_filter = .any
        }
        
        Internet.upload(discoverGender: master.discover_gender_filter)
    }
    
}

extension DiscoverFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RangeInputCell") as? RangeInputCell
            
            cell?.title.text = "Age"
            
            cell?.input.delegate = self
            
            cell?.input.selectedMaxValue = CGFloat(master.discover_max_filter_age)
            cell?.input.selectedMinValue = CGFloat(master.discover_min_filer_age)
            
            return cell!
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenderFilterInputCell") as? GenderFilterInputCell
            
            cell?.title.text = "Gender"
            
            cell?.selector?.addTarget(self, action: #selector(genderFilterChanged(_:)), for: .valueChanged)
            
            switch master.discover_gender_filter {
            case .any: cell?.selector.selectedSegmentIndex = 0
            case .female: cell?.selector.selectedSegmentIndex = 1
            case .male: cell?.selector.selectedSegmentIndex = 2
            case .non_binary: cell?.selector.selectedSegmentIndex = 3
            case .unknown: cell?.selector.selectedSegmentIndex = 0
            }
            
            return cell!
            
        default:
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 90
        case 1:
            return 60
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 44
        default:
            return 15
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Only people who meet these criteria will be shown in the discover tab and will be able to discover you in their discover tab."
        }
        return ""
    }
    
}

extension DiscoverFilterVC: RangeSeekSliderDelegate {
    
    func didEndTouches(in slider: RangeSeekSlider) {
        master.discover_min_filer_age = Int(slider.selectedMinValue)
        master.discover_max_filter_age = Int(slider.selectedMaxValue)
        
        Internet.upload(discoverMinAge: master.discover_min_filer_age, discoverMaxAge: master.discover_max_filter_age)
    }
    
}
