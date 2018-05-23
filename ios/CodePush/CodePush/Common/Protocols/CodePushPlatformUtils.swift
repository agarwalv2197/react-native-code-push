//
//  CodePushPlatformUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Interface describing the methods that should be implemented in platform-specific instances of utils.
 * It can be implemented via platform-specific singleton.
 */
protocol CodePushPlatformUtils {
    
    /**
     * Checks whether the specified package is latest.
     *
     * Parameter packageMetadata   info about the package to be checked.
     * Parameter currentAppVersion version of the currently installed application.
     * Returns: ```true``` if package is latest.
     * Throws: CodePushGeneralException some exception that might occur.
     */
    func isPackageLatest(_ packageMetadata: CodePushLocalPackage, _ currentAppVersion: String) -> Bool
    
    /**
     * Gets binary version apk build time.
     *
     * Returns: time in ms.
     * Throws: NumberFormatException exception parsing time.
     */
    func getBinaryResourcesModifiedTime() -> Int64
    
    /**
     * Clears debug cache files.
     *
     * Throws: IOException exception occurred during read/write operations.
     */
    func clearDebugCache()
}
