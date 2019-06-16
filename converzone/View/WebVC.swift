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
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebsite(search: "https://www.duckduckgo.com")
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        webView.allowsLinkPreview = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search
        
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
        
        if !Internet.isOnline(){
            return
        }
        
        var myURL: URL
        
        if search.isEmpty{
            myURL = URL(string: "https://www.duckduckgo.com")!
        }else{
            if search.isURL() {
                
                myURL = URL(string: search)!
                
            }else{
                
                myURL = URL(string: fromSimpleWordsToSearch(simpleWords: search))!
                
            }
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

extension WebVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y / view.frame.height
        
        if offset > 1 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.searchBar.alpha = 0
                self.searchBarTopConstraint.constant = -self.searchBar.frame.height
            }, completion: nil)
            
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.searchBar.alpha = 1
                self.searchBarTopConstraint.constant = 0
            }, completion: nil)
        }
        
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
        loadWebsite(search: searchBar.text ?? "https://duckduckgo.com")
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
