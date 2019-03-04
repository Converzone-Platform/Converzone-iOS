//
//  Message.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation
import MapKit

class Message {
    
    internal var date: Date?
    internal var sent: Bool?
    internal var is_sender: Bool?
}

//Color: blue
class TextMessage: Message {
    
    internal var text: String?
    internal var only_emojies: Bool?
}

//Color: green
class AudioMessage: Message {
    
    internal var path: String?
}

//Color: green
class ImageMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

//Color: green
class VideoMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

//Color: green
class GifMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

//Color: green
class LinkMessage: Message {
    
    internal var meta_image: String?
    internal var meta_text: String?
}

//Color: green
class LocationMessage: Message {
    
    internal var latitude: CLLocationCoordinate2D?
    internal var longitude: CLLocationCoordinate2D?
}

//Color: orange
class UserMessage: Message {
    
    internal var user_id: String?
}

//Color: orange
class ReflectionMessage: Message {
    
    internal var text: String?
}

//Color: orange
class WroteReflectionMessage: Message {
    
    internal var reflection: String?
}

// Color: red
class InformationMessage: Message{
    
    internal var text: String?
}

// Color: red
class CannotDisplayMessage: Message {
    // The user needs to update the app to see this message
    // The partner sent a message which has not been introduced with this version of the app
    
    internal var text: String?
}
