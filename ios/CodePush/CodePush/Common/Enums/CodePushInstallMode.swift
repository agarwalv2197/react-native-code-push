//
//  CodePushInstallMode.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushInstallMode: Int, Codable {
    
    /**
     * Indicates that you want to install the update and restart the app immediately.
     */
    case Immediate,
    
    /**
     * Indicates that you want to install the update, but not forcibly restart the app.
     */
    OnNextRestart,
    
    /**
     * Indicates that you want to install the update, but don't want to restart the
     * app until the next time the end user resumes it from the background.
     */
    OnNextResume,
    
    /**
     * Indicates that you want to install the update when the app is in the background,
     * but only after it has been in the background for "minimumBackgroundDuration" seconds (0 by default),
     * so that user context isn't lost unless the app suspension is long enough to not matter.
     */
    OnNextSuspend
}
