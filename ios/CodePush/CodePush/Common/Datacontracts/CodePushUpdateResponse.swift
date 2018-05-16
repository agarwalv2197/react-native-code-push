//
//  CodePushUpdateResponse.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushUpdateResponse : Codable {
    
    var updateInfo: CodePushUpdateResponseInfo
    
    init(_ updateInfo: CodePushUpdateResponseInfo) {
        self.updateInfo = updateInfo
    }
}
