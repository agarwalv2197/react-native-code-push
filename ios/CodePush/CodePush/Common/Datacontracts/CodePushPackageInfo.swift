//
//  CodePushPackageInfo.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Contains information about packages available for user.
 */
class CodePushPackageInfo: Codable {
    
    /**
     * Previously installed package hash.
     */
    var previousPackage: String?
    
    /**
     * Currently installed package hash.
     */
    var currentPackage: String?

    init() {}
}
