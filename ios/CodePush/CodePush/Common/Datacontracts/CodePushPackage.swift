//
//  CodePushPackage.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

public class CodePushPackage: Codable {
    
    /**
     * The app binary version that this update is dependent on. This is the value that was
     * specified via the appStoreVersion parameter when calling the CLI's release command.
     */
    public var appVersion: String?
    
    /**
     * The deployment key that was used to originally download this update.
     */
    public var deploymentKey: String?
    
    /**
     * The description of the update. This is the same value that you specified in the CLI when you released the update.
     */
    public var description: String?
    
    /**
     * Indicates whether this update has been previously installed but was rolled back.
     */
    public var failedInstall: Bool?
    
    /**
     * Indicates whether the update is considered mandatory.
     * This is the value that was specified in the CLI when the update was released.
     */
    public var isMandatory: Bool?
    
    /**
     * The internal label automatically given to the update by the CodePush server.
     * This value uniquely identifies the update within its deployment.
     */
    public var label: String?
    
    /**
     * The SHA hash value of the update.
     */
    public var packageHash: String?
    
    init() {}
}
