//
//  CodePushCheckFrequency.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushCheckFrequency: Int, Codable {
    
    case OnAppStart,
    OnAppResume,
    Manual
}
