//
//  StatusCodes.swift
//  converzone
//
//  Created by Goga Barabadze on 19.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation

func getLocalizedErrorMessage(from statusCode: Int) -> String {
    
    switch statusCode {
        
    case 1:
        return NSLocalizedString("Success", comment: "The device was able to connect with the server sucessfully")
        
    case 2:
        return NSLocalizedString("Success", comment: "The device was able to connect with the server sucessfully")
        
    case 3:
        return NSLocalizedString("Success", comment: "The device was able to connect with the server sucessfully")
        
    case 3:
        return NSLocalizedString("Success", comment: "The device was able to connect with the server sucessfully")
        
    default:
        return NSLocalizedString("Unknown error while connecting to server", comment: "The device was not able to connect to the server and we don't know what happened")
        
    }
    
}
