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
    @IBOutlet weak var progressView: UIProgressView!
    
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
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        UIView.animate(withDuration: 1, delay: 0.1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.progressView.progressTintColor = randomColor()
        })
        
        if self.webView.estimatedProgress >= 1.0 {
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {
                
                self.progressView.alpha = 0
                
            }) { (finished: Bool) in
                
                self.progressView.alpha = 0
                
            }
            
        }

        
    }
    
    func showProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 1
        }, completion: nil)
    }
    
    func hideProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
    
    func loadWebsite(search: String){
        
        var myURL: URL = URL(string: search)!
        
        if search.isURL() {
            
            myURL = URL(string: search)!
            
        }else{
            
            myURL = URL(string: fromSimpleWordsToSearch(simpleWords: search))!
            
        }
        
        let myRequest = URLRequest(url: myURL)
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
        hideProgressView()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressView()
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
