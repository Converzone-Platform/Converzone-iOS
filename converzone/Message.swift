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
    
    //Information about the message
    internal var date: Date?
    internal var sent: Bool?
    internal var is_sender: Bool?
}

class TextMessage: Message {
    
    internal var text: String?
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
    
    //Display metadata
    internal var meta_image: String?
    internal var meta_text: String?
}

class LocationMessage: Message {
    
    internal var latitude: CLLocationCoordinate2D?
    internal var longitude: CLLocationCoordinate2D?
    
    /*let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
    source.name = "Source"
    
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
    destination.name = "Destination"
    
    MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])*/
}

class UserMessage: Message {
    
    internal var user_id: String?
}
