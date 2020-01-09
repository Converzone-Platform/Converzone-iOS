//
//  Logger.swift
//  converzone
//
//  Created by Goga Barabadze on 23.11.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import os

class Logger {
    
    static func print (message: StaticString, args: CVarArg..., type: OSLogType = .default) {
        
        os_log(message, log: .default, type: type, args)
        
    }
    
}
