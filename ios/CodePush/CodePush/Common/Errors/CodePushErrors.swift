//
//  CodePushErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * General CodePushErrors
 */
enum CodePushErrors: Error {
    
    /**
     * Indicates an invalid parameter was passed
     */
    case invalidParam(cause: String)
    
    /**
     * Failed to initialize the object
     */
    case initialization(cause: String)
    
    /**
     * The package doesn't have a hash value
     */
    case noHashValue(cause: String)
    
    /**
     * Failed to merge the current package with the fetched package
     */
    case merge(cause: String)
    
    /**
     * Failed to unzip the fetched package
     */
    case unzip(cause: Error)
    
    /**
     * An error occured while checking for an update
     */
    case checkForUpdate(cause: Error)
    
    /**
     * An error occurred while syncing
     */
    case sync(cause: Error)
    
    /**
     * An error occurred while downloading the package
     */
    case download(cause: Error)
    
    /**
     * An error occurred while installing the package
     */
    case install(cause: String)
}
