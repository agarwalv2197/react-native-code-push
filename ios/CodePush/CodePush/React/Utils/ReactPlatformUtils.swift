//
//  ReactPlatformUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class ReactPlatformUtils : CodePushPlatformUtils {
    
    static let sharedInstance = ReactPlatformUtils()
    
    private init() {}
    
    func isPackageLatest(_ packageMetadata: CodePushLocalPackage, _ currentAppVersion: String) -> Bool {
        <#code#>
    }
    
    func getBinaryResourcesModifiedTime() -> Int64 {
        <#code#>
    }
    
    func clearDebugCache() {
        <#code#>
    }

}
