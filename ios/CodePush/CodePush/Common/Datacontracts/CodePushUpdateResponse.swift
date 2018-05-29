//
//  CodePushUpdateResponse.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * A response class containing info about the update.
 */
class CodePushUpdateResponse: Codable {
    
    /**
     * Information about the existing update.
     */
    var updateInfo: CodePushUpdateResponseInfo

    init(_ updateInfo: CodePushUpdateResponseInfo) {
        self.updateInfo = updateInfo
    }
}
