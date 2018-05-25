//
//  CodePushPlatformUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Protocol describing the methods that should be implemented in platform-specific instances of utils.
 * It can be implemented via platform-specific singleton.
 */
protocol CodePushPlatformUtils {

    /**
     * Checks whether the specified package is latest.
     *
     * Parameter packageMetadata   info about the package to be checked.
     * Parameter currentAppVersion version of the currently installed application.
     * Returns: ```true``` if package is latest.
     */
    func isPackageLatest(_ packageMetadata: CodePushLocalPackage, _ currentAppVersion: String) -> Bool

    /**
     * Gets binary version apk build time.
     *
     * Returns: time in ms.
     */
    func getBinaryResourcesModifiedTime() -> Int64

    /**
     * Clears debug cache files.
     *
     */
    func clearDebugCache()
}
