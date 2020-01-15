//
//  DonationVC.swift
//  converzone
//
//  Created by Goga Barabadze on 05.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit
import SAConfettiView
import StoreKit
import os

class DonationOptions {
    var price = "Loading..."
    var id = ""
    
    init(id: String) {
        self.id = id
    }
}

var tier_options = [DonationOptions(id: "com.hashtag.oct.converzone.tier1")]

class DonationVC: UIViewController {
    
    @IBOutlet weak var confetti: SAConfettiView!
    
    @IBAction func choose_an_amount(_ sender: Any) {
        
        for option in tier_options {
            loadPrices(id: option.id)
        }
        
        displayDonationOptions()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        for option in tier_options {
            loadPrices(id: option.id)
        }
    }
    
    override func viewDidLoad() {
        
        confetti.alpha = 0
        
        UIView.animate(withDuration: 2) {
            self.confetti.alpha = 1
        }
        
        confetti.type = .Image(UIImage(named: "red_heart")!)
        confetti.startConfetti()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        confetti.stopConfetti()
        
        UIView.animate(withDuration: 0.5) {
            self.confetti.alpha = 0
        }
    }
    
    private func displayDonationOptions(){
        
        let controller = UIAlertController(title: "Donate to converzone", message: "Choose an amount to donate. Click 'Cancel' if you accidently came here.", preferredStyle: .actionSheet)
        
        
        for option in tier_options {
            controller.addAction(UIAlertAction(title: option.price, style: .default, handler: { (alert_controller) in
                
                if SKPaymentQueue.canMakePayments() {
                    let paymentRequest = SKMutablePayment()
                    paymentRequest.productIdentifier = option.id
                    SKPaymentQueue.default().add(paymentRequest)
                }else{
                    alert("Cannot make Donation", "Your current settings do not support in-app purchases.")
                }
                
            }))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
        
    }
    
}

extension DonationVC: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState{
                
            case .purchased:
                os_log("Donated!")
                Internet.donated()
                
                alert("Thank you!", "You are the best!")
                
            case .deferred: fallthrough
            case .failed: fallthrough
            case .purchasing: fallthrough
            case .restored:
            
                os_log("Transaction state changed!")
                
            @unknown default:
                os_log("Unknown error during transaction")
            }
        }
    }
    
    func loadPrices(id: String){
        let productID: NSSet = NSSet(object: id);
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let validProducts = response.products
       if !validProducts.isEmpty {
           let validProduct: SKProduct = response.products[0] as SKProduct
           
           for option in tier_options {
                if option.id == validProduct.productIdentifier {
                    option.price = validProduct.localizedPrice
                }
           }
        
       } else {
           print("nothing")
       }
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
