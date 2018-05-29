//
//  QueryUpdateErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Errors occuring during an update query
 */
enum QueryUpdateErrors: Error {
    
    /**
     * Indicates no data was returned from the query
     */
    case noData
    
    /**
     * Failed to convert the returned data to JSON
     */
    case failedJsonConversion
    
    /**
     * Failed to construct the query URL
     */
    case failedToConstructUrl
}
