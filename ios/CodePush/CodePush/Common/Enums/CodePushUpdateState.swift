//
//  CodePushUpdateState.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Indicates the state that an update is currently in.
 */
public enum CodePushUpdateState {
    /**
     * Indicates that an update represents the
     * version of the app that is currently running.
     */
    case running,

    /**
     * Indicates than an update has been installed, but the
     * app hasn't been restarted yet in order to apply it.
     */
    pending,

    /**
     * Indicates than an update represents the latest available
     * release, and can be either currently running or pending.
     */
    latest
}
