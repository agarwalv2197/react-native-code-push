//
//  CodePushUpdateUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushUpdateUtils {
    
    static let sharedInstance = CodePushUpdateUtils()
    let fileUtils: FileUtils
    let codePushUtils: CodePushUtils
    
    private init() {
        self.fileUtils = FileUtils.sharedInstance
        self.codePushUtils = CodePushUtils.sharedInstance
    }
}
