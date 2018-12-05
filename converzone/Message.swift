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

class TextMessage: Message {
    
    internal var text: String?
    internal var only_emojies: Bool?
}

class AudioMessage: Message {
    
    internal var path: String?
}

class ImageMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

class VideoMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

class GifMessage: Message {
    
    internal var path: String?
    internal var link: String?
}

class LinkMessage: Message {
    
    internal var meta_image: String?
    internal var meta_text: String?
}

class LocationMessage: Message {
    
    internal var latitude: CLLocationCoordinate2D?
    internal var longitude: CLLocationCoordinate2D?
}

class UserMessage: Message {
    
    internal var user_id: String?
}

class ReflectionMessage: Message {
    
    internal var reflection: String?
}

class InformationMessage: Message{
    
    internal var text: String?
}
