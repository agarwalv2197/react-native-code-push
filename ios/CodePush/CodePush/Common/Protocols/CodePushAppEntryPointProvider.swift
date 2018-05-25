//
//  CodePushAppEntryPointProvider.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Protocol for providing information about application entry point.
 */
protocol CodePushAppEntryPointProvider {
    
    /**
     * Gets location of application entry point.
     *
     * Returns: location of application entry point.
     */
    func getAppEntryPoint() throws -> String
}
