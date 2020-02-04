//
//  MessageRenderingEngine.swift
//  converzone
//
//  Created by Goga Barabadze on 22.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit
import os

extension ChatVC {
    
    fileprivate func maskCorners(_ message: TextMessage, _ indexPath: IndexPath, _ cell: TextMessageCell) {
        
        cell.view.layer.maskedCorners = message.is_sender ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        let cornerToConnect = message.is_sender ? CACornerMask.layerMaxXMinYCorner : .layerMinXMinYCorner
        let cornerToConnect2 = message.is_sender ? CACornerMask.layerMaxXMaxYCorner : .layerMinXMaxYCorner

        if let last_message = chatOf.conversation[safe: indexPath.row - 1] {
            if last_message.is_sender == message.is_sender{
                cell.top_constraint.constant = 3

                cell.view.layer.maskedCorners.remove(cornerToConnect)
            }
        }

        if let next_message = chatOf.conversation[safe: indexPath.row + 1] {
            if next_message.is_sender == message.is_sender {
                cell.bottom_constraint.constant = 3
            }else{
                cell.view.layer.maskedCorners.insert(cornerToConnect2)
            }
        }else{
            cell.view.layer.maskedCorners.insert(cornerToConnect2)

        }
    }
    
    fileprivate func renderTextMessage(_ indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TextMessageCell", owner: self, options: nil)?.first as! TextMessageCell
        
        let message = chatOf.conversation[indexPath.row] as! TextMessage
        
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:))))
        
        cell.message_label.text = message.text.trimmingCharacters(in: .nonBaseCharacters)
        cell.selectionStyle = .none
        
        cell.message_label.textAlignment = message.is_sender ? .right : .left
        
        if message.only_emojies == false {
            
            cell.message_label.textColor = message.is_sender ? .white : .black
            cell.view.backgroundColor = message.is_sender ? Colors.blue : .white
            
            cell.view.roundCorners(radius: 18)
            cell.view.addShadow(opacity: 0.05)
            
        }else{
            
            cell.message_label.font = message.text.count <= 5 ? UIFont.systemFont(ofSize: 50) : UIFont.systemFont(ofSize: 30)
            
        }
        
        if ((cell.message_label.text?.widthWithConstrained(cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - 56) {

            cell.left_constraint.isActive = message.is_sender ? false : true
            cell.right_constraint.isActive = message.is_sender ? true : false
        }
        
//        if ((cell.message_label.text?.height(withConstrainedWidth: cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - 60){
//
//            cell.left_constraint.isActive = message.is_sender ? false : true
//            cell.right_constraint.isActive = message.is_sender ? true : false
//        }
        
        maskCorners(message, indexPath, cell)
        
        return cell
    }
    
    fileprivate func renderInformationMessage(_ indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("InformationMessageCell", owner: self, options: nil)?.first as! InformationMessageCell
        let message = chatOf.conversation[indexPath.row] as! InformationMessage
        
        cell.information.text = message.text
        
        cell.selectionStyle = .none
        
        cell.view.roundCorners(radius: 15)
        cell.view.addShadow(opacity: 0.05)
        
        return cell
    }
    
    fileprivate func renderNeedHelpMessage() -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("NeedHelpMessageCell", owner: self, options: nil)?.first as! NeedHelpMessageCell
        
        cell.title.text = "Need some help?"
        cell.message.text = "We have noticed that your partner acts a little weird."
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.view.roundCorners(radius: 15)
        cell.view.addShadow(opacity: 0.05)
        
        return cell
    }
    
    func renderMessageCell(_ indexPath: IndexPath) -> UITableViewCell {
        
        guard let message = chatOf.conversation[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        switch message {
            
        case is TextMessage: return renderTextMessage(indexPath)
            
        case is FirstInformationMessage: fallthrough
            
        case is InformationMessage: return renderInformationMessage(indexPath)
            
        case is NeedHelpMessage: return renderNeedHelpMessage()
            
        default:
            os_log("that is a new kind of message")
        }
        
        return UITableViewCell()
    }
    
}
