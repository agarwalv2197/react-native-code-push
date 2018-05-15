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
     * @param packageMetadata   info about the package to be checked.
     * @param currentAppVersion version of the currently installed application.
     * @param context           application context.
     * @return <code>true</code> if package is latest.
     * @throws CodePushGeneralException some exception that might occur.
     */
    func isPackageLatest(_ packageMetadata: CodePushLocalPackage, _ currentAppVersion: String) -> Bool
    
    /**
     * Gets binary version apk build time.
     *
     * @param context application context.
     * @return time in ms.
     * @throws NumberFormatException exception parsing time.
     */
    func getBinaryResourcesModifiedTime() -> Int64
    
    /**
     * Clears debug cache files.
     *
     * @param context application context.
     * @throws IOException exception occurred during read/write operations.
     */
    func clearDebugCache()
}
