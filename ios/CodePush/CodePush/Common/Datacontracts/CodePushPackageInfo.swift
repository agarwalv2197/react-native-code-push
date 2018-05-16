//
//  CodePushPackageInfo.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushPackageInfo : Codable {
    
    var previousPackage: String?
    var currentPackage: String?
    
    init() {}
}
