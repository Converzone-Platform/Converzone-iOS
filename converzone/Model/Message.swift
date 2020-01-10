//
//  Message.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation
import MapKit

class Message: Hashable, Codable {
    
    enum Keys: String, CodingKey {
        
        case date
        
        case sent
        
        case color
        
        case is_sender
        
        case opened
        
    }
    
    internal var date: Date = Date()
    
    internal var sent: Bool = true
    
    internal var color: UIColor = Colors.blue
    
    internal var is_sender = true
    
    internal var opened = false
    
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var hashValue: Int {
        return self.date.hashValue ^ self.color.hashValue ^ self.sent.hashValue
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(date, forKey: .date)
        try container.encode(sent, forKey: .sent)
//        try container.encode(color, forKey: .color)
        try container.encode(is_sender, forKey: .is_sender)
        try container.encode(opened, forKey: .opened)
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: Keys.self)
        
        date = try container.decode(Date.self, forKey: .date)
        sent = try container.decode(Bool.self, forKey: .sent)
//        try container.decode(UIColor.self, forKey: .color)
        is_sender = try container.decode(Bool.self, forKey: .is_sender)
        opened = try container.decode(Bool.self, forKey: .opened)
        
    }
    
    init() {
        
    }
}

//Color: blue
class TextMessage: Message {
    
    enum TextMessageKeys: String, CodingKey {
        
        case text
    }
    
    internal var text: String = ""
    
    internal var only_emojies: Bool {
        return text.contains_only_emoji
    }
    
    init(text: String, is_sender: Bool) {
        super.init()
        
        self.text = text
        self.is_sender = is_sender
        self.date = Date()
        self.color = Colors.blue
    }
    
    override init() {
        super.init()
        
        self.color = Colors.blue
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: TextMessageKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: TextMessageKeys.self)
        
        try container.encode(text, forKey: .text)
    }
    
    override var hashValue: Int {
        return super.hashValue ^ self.text.hashValue
    }
}

//Color: green
//class AudioMessage: Message {
//
//    internal var path: String?
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}

//Color: green
//class ImageMessage: Message {
//
//    internal var path: String?
//
//    internal var link: String?
//
//    internal var image: UIImage?
//
//
//    init(image: UIImage, is_sender: Bool) {
//
//        super.init()
//
//        self.image = image
//        self.is_sender = is_sender
//
//        //MARK: TODO - Change this to the received time
//        self.date = Date()
//
//        self.color = Colors.green
//    }
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}

//Color: green
//class VideoMessage: Message {
//
//    internal var path: String?
//
//    internal var link: String?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: green
//class GifMessage: Message {
//
//    internal var path: String?
//
//    internal var link: String?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: green
//class LinkMessage: Message {
//
//    internal var meta_image: String?
//
//    internal var meta_text: String?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: green
//class LocationMessage: Message {
//
//    internal var coordinate: CLLocationCoordinate2D?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.green
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: orange
//class UserMessage: Message {
//
//    internal var user_id: String?
//
//    internal var user: User?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.orange
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: orange
//class ReflectionMessage: Message {
//
//    internal var text: String?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.orange
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
////Color: orange
//class WroteReflectionMessage: Message {
//
//    internal var reflection: String?
//
//
//    override init() {
//        super.init()
//
//        self.color = Colors.orange
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}
//
//// Color: red
class InformationMessage: Message{
    
    enum InformationMessageKeys: String, CodingKey {
        
        case text
    }
    

    internal var text: String?


    override init() {
        super.init()

        self.color = Colors.red
    }

    required init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: InformationMessageKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: InformationMessageKeys.self)
        
        try container.encode(text, forKey: .text)
        
    }

    override var hashValue: Int {
        return super.hashValue ^ self.text!.hashValue
    }
}

// Color: red
class ScreenshotMessage: Message{

    override init() {
        super.init()

        self.color = Colors.red
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override var hashValue: Int {
        return super.hashValue ^ self.date.hashValue
    }
}

// Color: blue
class FirstInformationMessage: InformationMessage {
    
    override init(){
        super.init()
        
        self.color = Colors.blue
        
        super.text = "Be creative with the first message :)"
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

// Color: red
//class CannotDisplayMessage: Message {
//
//    internal var text: String?
//
//    override init() {
//        super.init()
//
//        self.color = Colors.red
//    }
//
//    required init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//}

class ReminderMessage: Message {
    
}

class NeedHelpMessage: Message {
    
}
