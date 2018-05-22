//
//  CodePushBuilder.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


public class CodePushBuilder: CodePushBuildable {
    
    private var deploymentKey: String = ""
    private var serverUrl: String = ""
    private var appEntryPoint: String = ""
    private var appSecret: String = ""
    private var appName: String = ""
    private var appVersion: String = ""
    private var baseDirectory: URL?
    
    public func result() -> CodePush? {
        if isValid {
            do {
                let codePush = try CodePush(self.deploymentKey,
                                            self.serverUrl,
                                            self.appEntryPoint,
                                            self.appSecret,
                                            self.appName,
                                            self.appVersion,
                                            self.baseDirectory)
                return codePush
            } catch {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    var isValid: Bool {
        return !deploymentKey.isEmpty
    }
    
    public func setDeploymentKey(key deploymentKey: String) {
        self.deploymentKey = deploymentKey
    }
    
    public func setServerUrl(url serverUrl: String) {
        self.serverUrl = serverUrl
    }
    
    public func setAppEntryPoint(entryPoint appEntryPoint: String) {
        self.appEntryPoint = appEntryPoint
    }
    
    public func setAppSecret(secret appSecret: String) {
        self.appSecret = appSecret
    }
    
    public func setAppName(name appName: String) {
        self.appName = appName
    }
    
    public func setAppVersion(version appVersion: String) {
        self.appVersion = appVersion
    }
    
    public func setBaseDirectory(directory baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }
    
    public init() {}
}

public struct CodePush {
    var deploymentKey: String
    var serverUrl: String?
    var appEntryPoint: String?
    var appSecret: String?
    var appName: String?
    var appVersion: String?
    var baseDirectory: URL?
    var reactCore: CodePushReactNativeCore
    
    init(_ deploymentKey: String, _ serverUrl: String, _ appEntryPoint: String,
         _ appSecret: String, _ appName: String, _ appVersion: String,
         _ baseDirectory: URL?) throws {
        
        self.deploymentKey = deploymentKey
        self.serverUrl = serverUrl
        self.appEntryPoint = appEntryPoint
        self.appSecret = appSecret
        self.appName = appName
        self.appVersion = appVersion
        self.baseDirectory = baseDirectory
        self.reactCore = try CodePushReactNativeCore(deploymentKey, serverUrl, appSecret, appName, appVersion, baseDirectory,
                                                     CodePushReactAppEntryPointProvider(appEntryPoint), ReactPlatformUtils.sharedInstance)
    }
    
    /**
     * Gets native CodePush configuration.
     *
     * @return native CodePush configuration.
     */
    public func getConfiguration() throws -> CodePushConfiguration? {
        return try self.reactCore.getNativeConfiguration()
    }
    
    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using deploymentKey already set in constructor.
     *
     * @return remote package info if there is an update, <code>null</code> otherwise.
     */
    public func checkForUpdate(callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        reactCore.checkForUpdate(callback: completion)
    }
    
    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using specified deployment key.
     *
     * @param deploymentKey deployment key to use.
     * @return remote package info if there is an update, <code>null</code> otherwise.
     */
    public func checkForUpdate(withKey deploymentKey: String,
                        callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        reactCore.checkForUpdate(withKey: deploymentKey, callback: completion)
    }
    
    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified <code>updateState</code> parameter.
     *
     * @param updateState current update state.
     * @return installed update metadata.
     */
    public func getUpdateMetadata(inUpdateState updateState: CodePushUpdateState) throws -> CodePushLocalPackage? {
        return try reactCore.getUpdateMetadata(inUpdateState: updateState)
    }
    
    /**
     * Synchronizes your app assets with the latest release to the configured deployment using default sync options.
     */
    public func sync(callback completion: @escaping (Result<Bool>) -> Void) {
        reactCore.sync(callback: completion)
    }
    
    /**
     * Synchronizes your app assets with the latest release to the configured deployment.
     *
     * @param syncOptions sync options.
     */
    public func sync(withOptions syncOptions: CodePushSyncOptions,
              callback completion: @escaping (Result<Bool>) -> Void){
        reactCore.sync(withOptions: syncOptions, callback: completion)
    }
}
