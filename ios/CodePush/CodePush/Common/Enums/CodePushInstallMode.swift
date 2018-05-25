//
//  CodePushInstallMode.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Indicates when you would like an installed update to actually be applied.
 */
enum CodePushInstallMode: Int, Codable {

    /**
     * Indicates that you want to install the update and restart the app immediately.
     */
    case immediate,
    
    /**
     * Indicates that you want to install the update, but not forcibly restart the app.
     */
    onNextRestart,

    /**
     * Indicates that you want to install the update, but don't want to restart the
     * app until the next time the end user resumes it from the background.
     */
    onNextResume,

    /**
     * Indicates that you want to install the update when the app is in the background,
     * but only after it has been in the background for "minimumBackgroundDuration" seconds (0 by default),
     * so that user context isn't lost unless the app suspension is long enough to not matter.
     */
    onNextSuspend
}
