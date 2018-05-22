//
//  CodePushUpdateState.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

public enum CodePushUpdateState {
    /**
     * Indicates that an update represents the
     * version of the app that is currently running.
     */
    case RUNNING,
    
    /**
     * Indicates than an update has been installed, but the
     * app hasn't been restarted yet in order to apply it.
     */
    PENDING,
    
    /**
     * Indicates than an update represents the latest available
     * release, and can be either currently running or pending.
     */
    LATEST
}
