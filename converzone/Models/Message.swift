//
//  Message.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation
import MapKit

class Message: Hashable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var hashValue: Int {
        return self.date!.hashValue ^ self.color.hashValue ^ self.sent.hashValue
    }
    
    internal var date: Date?
    internal var sent: Bool? = true
    internal var color: UIColor?
}

//Color: blue
class TextMessage: Message {
    
    internal var text: String?
    internal var only_emojies: Bool?{
        get{
            return text?.containsOnlyEmoji
        }
        set{
            // Don't do anything here
        }
    }
    
    internal var is_sender: Bool? = false
    
    init(text: String, is_sender: Bool) {
        super.init()
        
        self.text = text
        self.is_sender = is_sender
        
        //MARK: TODO - Change this to the received time
        self.date = Date()
        
        self.color = Colors.blue
    }
    
    override init() {
        super.init()
        
        self.color = Colors.blue
    }
    
    override var hashValue: Int {
        return super.hashValue ^ self.text!.hashValue
    }
}

//Color: green
class AudioMessage: Message {
    
    internal var path: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: green
class ImageMessage: Message {
    
    internal var path: String?
    internal var link: String?
    internal var is_sender: Bool?
    
    
    // For testing purposes
    internal var image: UIImage?
    
    init(image: UIImage, is_sender: Bool) {
        
        super.init()
        
        self.image = image
        self.is_sender = is_sender
        
        //MARK: TODO - Change this to the received time
        self.date = Date()
        
        self.color = Colors.green
    }
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: green
class VideoMessage: Message {
    
    internal var path: String?
    internal var link: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: green
class GifMessage: Message {
    
    internal var path: String?
    internal var link: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: green
class LinkMessage: Message {
    
    internal var meta_image: String?
    internal var meta_text: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: green
class LocationMessage: Message {
    
    internal var coordinate: CLLocationCoordinate2D?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.green
    }
}

//Color: orange
class UserMessage: Message {
    
    internal var user_id: String?
    internal var is_sender: Bool?
    
    
    // Please delete me when the final release is about to happen
    internal var user: User?
    
    override init() {
        super.init()
        
        self.color = Colors.orange
    }
}

//Color: orange
class ReflectionMessage: Message {
    
    internal var text: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.orange
    }
}

//Color: orange
class WroteReflectionMessage: Message {
    
    internal var reflection: String?
    internal var is_sender: Bool?
    
    override init() {
        super.init()
        
        self.color = Colors.orange
    }
}

// Color: red
class InformationMessage: Message{
    
    internal var text: String?
    
    override init() {
        super.init()
        
        self.color = Colors.red
    }
    
    override var hashValue: Int {
        return super.hashValue ^ self.text!.hashValue
    }
}

// Color: blue
class FirstInformationMessage: InformationMessage {
    
    override init(){
        super.init()
        
        self.color = Colors.blue
        
        super.text = "Be creative with the first message :)"
    }
}

// Color: red
class CannotDisplayMessage: Message {
    // The user needs to update the app to see this message
    // The partner sent a message which has not been introduced with this version of the app
    
    internal var text: String?
    
    override init() {
        super.init()
        
        self.color = Colors.red
    }
}

class ReminderMessage: Message {
    
}
