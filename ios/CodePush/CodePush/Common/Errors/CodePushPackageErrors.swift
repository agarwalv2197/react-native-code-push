//
//  CodePushPackageErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Errors that can occur performing actions with a CodePushPackage
 */
enum CodePushPackageErrors: Error {
    
    /**
     * Failed to rollback the package
     */
    case failedRollback(cause: Error)
    
    /**
     * Failed to install the package
     */
    case failedInstall(cause: Error)
    
    /**
     * Failed to download the package
     */
    case failedDownload(cause: Error)
}
