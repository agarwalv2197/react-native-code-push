//
//  CodePushRemotePackage.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

public class CodePushRemotePackage: CodePushPackage {
    
    public var downloadURL: URL?
    public var packageSize: Int64?
    public var updateAppVersion: Bool?
    
    override init() {
        super.init()
    }
    
    private enum CodingKeys: String, CodingKey {
        case downloadURL,
        packageSize,
        updateAppVersion
    }
    
    required public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        try super.init(from: superdecoder)
        
        self.downloadURL = try container.decode(URL.self, forKey: .downloadURL)
        self.packageSize = try container.decode(Int64.self, forKey: .packageSize)
        self.updateAppVersion = try container.decode(Bool.self, forKey: .updateAppVersion)
    }
    
    override public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(downloadURL, forKey: .downloadURL)
        try container.encode(packageSize, forKey: .packageSize)
        try container.encode(updateAppVersion, forKey: .updateAppVersion)
        let superdecoder = container.superEncoder()
        try super.encode(to: superdecoder)
    }
    
    /**
     * Creates an instance of the class from the basic codepush package.
     *
     * Parameter failedInstall    whether this update has been previously installed but was rolled back.
     * Parameter packageSize      the size of the package.
     * Parameter downloadUrl      url to access package on server.
     * Parameter updateAppVersion whether the client should trigger a store update.
     * Parameter codePushPackage  basic package containing the information.
     * Returns: instance of the {@link CodePushRemotePackage}.
     */
    static func createRemotePackage(fromFailedInstall failedInstall: Bool, size packageSize: Int64,
                                    atUrl downloadURL: URL, updateVersion updateAppVersion: Bool,
                                    fromPackage package: CodePushPackage) -> CodePushRemotePackage {
        let remotePackage = CodePushRemotePackage()
        remotePackage.appVersion = package.appVersion
        remotePackage.deploymentKey = package.deploymentKey
        remotePackage.description = package.description
        remotePackage.isMandatory = package.isMandatory
        remotePackage.label = package.label
        remotePackage.packageHash = package.packageHash
        remotePackage.failedInstall = failedInstall
        remotePackage.downloadURL = downloadURL
        remotePackage.packageSize = packageSize
        remotePackage.updateAppVersion = updateAppVersion
        return remotePackage
    }
    
    /**
     * Creates instance of the class from the update response from server.
     *
     * Parameter deploymentKey the deployment key that was used to originally download this update.
     * Parameter updateInfo    update info response from server.
     * Returns: instance of the {@link CodePushRemotePackage}.
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
        remotePackage.downloadURL = URL(string: updateInfo.downloadURL!)
        remotePackage.updateAppVersion = updateInfo.updateAppVersion
        return remotePackage
    }
    
    /**
     * Creates a default package from the app version.
     *
     * Parameter appVersion       current app version.
     * Parameter updateAppVersion whether the client should trigger a store update.
     * Returns: instance of the {@link CodePushRemotePackage}.
     */
    static func createDefaultRemotePackage(withVersion appVersion: String,
                                           updateVersion updateAppVersion: Bool) -> CodePushRemotePackage {
        let remotePackage = CodePushRemotePackage()
        remotePackage.appVersion = appVersion
        remotePackage.updateAppVersion = updateAppVersion
        return remotePackage
    }
}
