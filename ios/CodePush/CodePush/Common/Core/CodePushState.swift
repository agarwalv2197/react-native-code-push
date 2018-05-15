//
//  CodePushState.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushState {
    
    /**
     * Indicates whether a new update running for the first time.
     */
    var didUpdate: Bool?
    
    /**
     * Indicates whether there is a need to send rollback report.
     */
    var NeedToReportRollback: Bool?
    
    /**
     * Indicates whether current install mode.
     */
    var currentInstallModeInProgress: CodePushInstallMode?
    
    /**
     * Indicates whether is running binary version of app.
     */
    var isRunningBinaryVersion: Bool?
    
    /**
     * Indicates whether sync already in progress.
     */
    var syncInProgress: Bool?
    
    /**
     * Minimum background duration value.
     */
    var minimumBackgroundDuration: Int?
}
