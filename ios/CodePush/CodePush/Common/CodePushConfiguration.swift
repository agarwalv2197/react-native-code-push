//
//  CodePushConfiguration.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


public class CodePushConfiguration {
    
    /**
     * Application name, if provided.
     */
    var appName: String?
    
    /**
     * Semantic version for app for use when getting updates, if provided.
     */
    var appVersion: String?
    
    /**
     * Android client unique id.
     */
    var clientUniqueId: String?
    
    /**
     * CodePush deployment key.
     */
    var deploymentKey: String?
    
    /**
     * CodePush base directory, if provided.
     */
    var baseDirectory: URL?
    
    /**
     * CodePush acquisition server URL.
     */
    var serverUrl: String?
    
    /**
     * Package hash of currently running CodePush update.
     * See ```CodePushUpdateState``` for details.
     */
    var packageHash: String?
    
    init() {}
}
