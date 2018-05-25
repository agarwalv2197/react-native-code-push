//
//  CodePushCheckFrequency.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Indicates when you would like to check for (and install) updates from the CodePush server.
 */
enum CodePushCheckFrequency: Int, Codable {
    
    /**
     * When the app is fully initialized (or more specifically, when the root component is mounted).
     */
    case onAppStart,

    /**
     * When the app re-enters the foreground.
     */
    onAppResume,

    /**
     * Don't automatically check for updates, but only do it when ```codePush.sync()```
     * is manually called inside app code.
     */
    manual
}
