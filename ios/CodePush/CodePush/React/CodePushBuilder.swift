//
//  CodePushBuilder.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * A builder for the ```CodePush``` struct.
 */
public class CodePushBuilder: CodePushBuildable {

    /**
     * Deployment key for checking for updates.
     */
    private var deploymentKey: String = ""
    
    /**
     * CodePush server URL.
     */
    private var serverUrl: String = ""
    
    /**
     * Entry point for application.
     */
    private var appEntryPoint: String = ""
    
    /**
     * App secret used to configure the AppCentre CrashSDK
     */
    private var appSecret: String = ""
    
    /**
     * Current app name.
     */
    private var appName: String = ""
    
    /**
     * Semantic version for app for use when getting updates.
     * If not provided, defaults to ```CFBundleShortVersionString``` field from the application bundle
     */
    private var appVersion: String = ""
    
    /**
     * Base directory for CodePush files.
     * If not provided, defaults to the devices documents directory
     */
    private var baseDirectory: URL?

    /**
     * Attempt to build an instance of CodePush
     * Returns: An instance of CodePush or ```nil```
     */
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

    /**
     * Gatekeeper that prevents the construction of CodePush if the
     * required fields are not populated.
     */
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

/**
 * A Struct exposing the CodePush API to users.
 */
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
        self.reactCore = try CodePushReactNativeCore(deploymentKey, serverUrl, appSecret,
                                                     appName, appVersion, baseDirectory,
                                                     CodePushReactAppEntryPointProvider(appEntryPoint),
                                                     ReactPlatformUtils.sharedInstance)
    }

    /**
     * Gets native CodePush configuration.
     *
     * Returns: native CodePush configuration.
     */
    public func getConfiguration() throws -> CodePushConfiguration? {
        return try self.reactCore.getNativeConfiguration()
    }

    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using deploymentKey already set in constructor.
     *
     * Parameter completion completion handler.
     * Returns: remote package info if there is an update, ```nil``` otherwise.
     */
    public func checkForUpdate(callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        reactCore.checkForUpdate(callback: completion)
    }

    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using specified deployment key.
     *
     * Parameter deploymentKey deployment key to use.
     * Parameter completion completion handler.
     * Returns: remote package info if there is an update, ```nil``` otherwise.
     */
    public func checkForUpdate(withKey deploymentKey: String,
                               callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        reactCore.checkForUpdate(withKey: deploymentKey, callback: completion)
    }

    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified ```updateState``` parameter.
     *
     * Parameter updateState current update state.
     * Returns: installed update metadata.
     */
    public func getUpdateMetadata(inUpdateState updateState: CodePushUpdateState) throws -> CodePushLocalPackage? {
        return try reactCore.getUpdateMetadata(inUpdateState: updateState)
    }

    /**
     * Synchronizes your app assets with the latest release to the configured deployment using default sync options.
     * Parameter completion completion handler.
     */
    public func sync(callback completion: @escaping (Result<Bool>) -> Void) {
        reactCore.sync(callback: completion)
    }

    /**
     * Synchronizes your app assets with the latest release to the configured deployment.
     *
     * Parameter syncOptions sync options.
     * Parameter completion completion handler.
     */
//    public func sync(withOptions syncOptions: CodePushSyncOptions,
//              callback completion: @escaping (Result<Bool>) -> Void){
//        reactCore.sync(withOptions: syncOptions, callback: completion)
//    }

    /**
     * Return the path to the directory that contains the current bundle
     * Returns: directory of current bundle or nil
     */
    public func getCurrentPackagePath() throws -> URL? {
        return try reactCore.getCurrentPackagePath()
    }

    /**
     * Return the path to the directory that contains the previous bundle
     * Returns: directory of previous bundle or nil
     */
    public func getPreviousPackagePath() throws -> URL? {
        return try reactCore.getPreviousPackagePath()
    }
}
