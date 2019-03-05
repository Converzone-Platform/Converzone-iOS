//
//  WebVC.swift
//  converzone
//
//  Created by Goga Barabadze on 13.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding webView content
        do {
            guard let filePath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "home_screen")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }

            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        } catch {
            print ("File HTML error")
        }

        webView.uiDelegate = self
        webView.navigationDelegate = self

        webView.allowsLinkPreview = false
        
       
    }
    
    
    
    func loadWebsite(search: String){
        
        let myURL = URL(string: fromSimpleWordsToSearch(simpleWords: search))
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func fromSimpleWordsToSearch(simpleWords: String) -> String{
    
        let components = simpleWords.components(separatedBy: " ")
        
        var new = "https://duckduckgo.com/?q="
        
        for i in 0...components.count - 1{
            new += "+" + components[i]
        }
        
        return new
    }
    
}

extension WebVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            webView.alpha = 1
            
            
            
        }, completion: nil)

    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            webView.alpha = 0.3
            
        
            
        }, completion: nil)
        
        webView.alpha = 0

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            webView.alpha = 1
            
            
            
        }, completion: nil)
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.encodedOffset
        } else {
            return false
        }
    }
}

extension WebVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadWebsite(search: searchBar.text ?? "")
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
}

extension WebVC: UITextFieldDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
