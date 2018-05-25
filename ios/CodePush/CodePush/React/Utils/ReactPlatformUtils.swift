//
//  ReactPlatformUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class ReactPlatformUtils: CodePushPlatformUtils {

    static let sharedInstance = ReactPlatformUtils()

    private init() {}

    func isPackageLatest(_ packageMetadata: CodePushLocalPackage, _ currentAppVersion: String) -> Bool {
        return true
    }

    func getBinaryResourcesModifiedTime() -> Int64 {
        return 1000
    }

    func clearDebugCache() {

    }

}
