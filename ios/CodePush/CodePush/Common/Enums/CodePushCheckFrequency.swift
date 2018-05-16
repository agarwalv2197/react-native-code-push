//
//  CodePushCheckFrequency.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushCheckFrequency: Int, Codable {
    
    case ON_APP_START,
    ON_APP_RESUME,
    MANUAL
}
