//
//  CodePushRemotePackage.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushRemotePackage: CodePushPackage {
    
    var downloadUrl: String?
    var packageSize: Int64?
    var updateAppVersion: Bool?
    
    override init() {}
    
    /**
     * Creates an instance of the class from the basic codepush package.
     *
     * @param failedInstall    whether this update has been previously installed but was rolled back.
     * @param packageSize      the size of the package.
     * @param downloadUrl      url to access package on server.
     * @param updateAppVersion whether the client should trigger a store update.
     * @param codePushPackage  basic package containing the information.
     * @return instance of the {@link CodePushRemotePackage}.
     */
    static func createRemotePackage(fromFailedInstall failedInstall: Bool, size packageSize: Int64,
                                    atUrl downloadUrl: String, updateVersion updateAppVersion: Bool,
                                    fromPackage package: CodePushPackage) -> CodePushRemotePackage {
        let remotePackage = CodePushRemotePackage()
        remotePackage.appVersion = package.appVersion
        remotePackage.deploymentKey = package.deploymentKey
        remotePackage.description = package.description
        remotePackage.isMandatory = package.isMandatory
        remotePackage.label = package.label
        remotePackage.packageHash = package.packageHash
        remotePackage.failedInstall = failedInstall
        remotePackage.downloadUrl = downloadUrl
        remotePackage.packageSize = packageSize
        remotePackage.updateAppVersion = updateAppVersion
        return remotePackage
    }
    
    /**
     * Creates instance of the class from the update response from server.
     *
     * @param deploymentKey the deployment key that was used to originally download this update.
     * @param updateInfo    update info response from server.
     * @return instance of the {@link CodePushRemotePackage}.
     */
    static func createRemotePackage(withDeploymentKey deploymentKey: String,
                                    fromUpdateInfo updateInfo: CodePushUpdateResponseInfo) -> CodePushRemotePackage{
        let remotePackage = CodePushRemotePackage()
        remotePackage.appVersion = updateInfo.appVersion
        remotePackage.deploymentKey = deploymentKey
        remotePackage.description = updateInfo.description
        remotePackage.failedInstall = false
        remotePackage.isMandatory = updateInfo.isMandatory
        remotePackage.label = updateInfo.label
        remotePackage.packageHash = updateInfo.packageHash
        remotePackage.packageSize = updateInfo.packageSize
        remotePackage.downloadUrl = updateInfo.downloadUrl
        remotePackage.updateAppVersion = updateInfo.updateAppVersion
        return remotePackage
    }
    
    /**
     * Creates a default package from the app version.
     *
     * @param appVersion       current app version.
     * @param updateAppVersion whether the client should trigger a store update.
     * @return instance of the {@link CodePushRemotePackage}.
     */
    static func createDefaultRemotePackage(withVersion appVersion: String,
                                           updateVersion updateAppVersion: Bool) -> CodePushRemotePackage {
        let remotePackage = CodePushRemotePackage()
        remotePackage.appVersion = appVersion
        remotePackage.updateAppVersion = updateAppVersion
        return remotePackage
    }
}
