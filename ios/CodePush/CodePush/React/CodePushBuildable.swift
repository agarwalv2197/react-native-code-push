//
//  CodePushBuildable.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


protocol CodePushBuildable {
    
    /**
     * Application deployment key.
     */
    func setDeploymentKey(key deploymentKey: String)
    
    /**
     * CodePush server URL.
     */
    func setServerUrl(url serverUrl: String)
    
    /**
     * Path to the application entry point.
     */
    func setAppEntryPoint(entryPoint appEntryPoint: String)
    
    /**
     * The value of app secret from AppCenter portal to configure Crashes sdk.
     */
    func setAppSecret(secret appSecret: String)
    
    /**
     * App name for use when utilizing multiple CodePush instances to differentiate file locations.
     * If not provided, defaults to CodePushConstants.CodePushDefaultAppName.
     */
    func setAppName(name appName: String)
    
    /**
     * Semantic version for app for use when getting updates.
     * If not provided, defaults to ```versionString``` from the bundle
     */
    func setAppVersion(version appVersion: String)
    
    /**
     * Base directory for CodePush files.
     * If not provided, defaults to documents directory
     */
    func setBaseDirectory(directory baseDirectory: URL)
    
    /**
    * Return the CodePush instance if possible
    */
    func result() -> CodePush?
    
    /**
    * Whether the builder can build a CodePush instance
    */
    var isValid: Bool {get}
}
