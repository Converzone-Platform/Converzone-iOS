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

    @IBOutlet weak var web_view: WKWebView!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    @IBOutlet weak var progress_view: UIProgressView!
    
    @IBOutlet weak var search_bar_top_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var explanation_label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebsite(search: "https://www.duckduckgo.com")
        
        web_view.uiDelegate = self
        web_view.navigationDelegate = self
        web_view.scrollView.delegate = self
        
        web_view.allowsLinkPreview = false
        
        web_view.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        search_bar.autocapitalizationType = .none
        search_bar.returnKeyType = .search
        
        if master.browser_introductory_text_shown == false {
            
            NotificationCenter.default.addObserver(self, selector: #selector(fadeAwayBrowserIntroductoryText), name: UIApplication.keyboardWillShowNotification, object: nil)
            
            explanation_label.alpha = 0
            
            UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
                self.explanation_label.alpha = 1
            }, completion: nil)
        }
        
    }
    
    @objc func fadeAwayBrowserIntroductoryText () {
        
        master.browser_introductory_text_shown = true
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
            self.explanation_label.alpha = 0
        }, completion: nil)
        
        Internet.upload(browser_introductory_text_shown: true)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        UIView.animate(withDuration: 1, delay: 0.1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.progress_view.progressTintColor = Colors.random()
        })
        
        if self.web_view.estimatedProgress >= 1.0 {
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {
                
                self.progress_view.alpha = 0
                
            }) { (finished: Bool) in
                
                self.progress_view.alpha = 0
                
            }
            
        }

        
    }
    
    private func showProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progress_view.alpha = 1
        }, completion: nil)
    }
    
    private func hideProgressView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.progress_view.alpha = 0
        }, completion: nil)
    }
    
    private func loadWebsite(search: String){
        
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
        
        web_view.load(URLRequest(url: myURL))
    }
    
    private func fromSimpleWordsToSearch(simpleWords: String) -> String{
    
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
                self.search_bar.alpha = 0
                self.search_bar_top_constraint.constant = -self.search_bar.frame.height
            }, completion: nil)
            
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.search_bar.alpha = 1
                self.search_bar_top_constraint.constant = 0
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
