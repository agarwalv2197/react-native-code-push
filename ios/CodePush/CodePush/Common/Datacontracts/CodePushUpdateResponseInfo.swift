//
//  CodePushUpdateResponseInfo.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Update info from the server.
 */
class CodePushUpdateResponseInfo: Codable {
    
    /**
     * Url to access package on server.
     */
    var downloadURL: String?

    /**
     * The description of the update.
     * This is the same value that you specified in the CLI when you released the update.
     */
    var description: String?

    /**
     * Whether the package is available (```false``` if it it disabled).
     */
    var isAvailable: Bool?

    /**
     * Indicates whether the update is considered mandatory.
     * This is the value that was specified in the CLI when the update was released.
     */
    var isMandatory: Bool?

    /**
     * The app binary version that this update is dependent on. This is the value that was
     * specified via the appStoreVersion parameter when calling the CLI's release command.
     */
    var appVersion: String?

    /**
     * The SHA hash value of the update.
     */
    var packageHash: String?

    /**
     * The internal label automatically given to the update by the CodePush server.
     * This value uniquely identifies the update within its deployment.
     */
    var label: String?

    /**
     * Size of the package.
     */
    var packageSize: Int64?
    
    /**
     * Whether the client should trigger a store update.
     */
    var updateAppVersion: Bool?

    /**
     * Set to ```true``` if the update directs to use the binary version of the application.
     */
    var shouldRunBinaryVersion: Bool?

    init() {}

}
