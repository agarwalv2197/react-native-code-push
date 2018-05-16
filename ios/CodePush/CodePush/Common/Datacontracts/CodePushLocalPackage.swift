//
//  CodePushLocalPackage.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushLocalPackage: CodePushPackage {
    
    /**
     * Indicates whether this update is in a "pending" state.
     * When <code>true</code>, that means the update has been downloaded and installed, but the app restart
     * needed to apply it hasn't occurred yet, and therefore, its changes aren't currently visible to the end-user.
     */
    var isPending: Bool?
    
    /**
     * The path to the application entry point (e.g. android.js.bundle for RN, index.html for Cordova).
     */
    var appEntryPoint: String?
    
    /**
     * Indicates whether this is the first time the update has been run after being installed.
     */
    var isFirstRun: Bool?
    
    /**
     * Whether this package is intended for debug mode.
     */
    var isDebugOnly: Bool?
    
    /**
     *
     */
    var binaryModifiedTime: String?
    
    private enum CodingKeys: String, CodingKey {
        case isPending,
        appEntryPoint,
        isFirstRun,
        isDebugOnly,
        binaryModifiedTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isPending = try container.decode(Bool.self, forKey: .isPending)
        self.appEntryPoint = try container.decode(String.self, forKey: .appEntryPoint)
        self.isFirstRun = try container.decode(Bool.self, forKey: .isFirstRun)
        self.isDebugOnly = try container.decode(Bool.self, forKey: .isDebugOnly)
        self.binaryModifiedTime = try container.decode(String.self, forKey: .binaryModifiedTime)
        try super.init(from: decoder)
    }
    
    static func createLocalPackage(wasFailedInstall failedInstall: Bool, isFirstRun firstRun: Bool,
                                   isPending pending: Bool, withEntryPoint entryPoint: String,
                                   fromPackage package: CodePushPackage) -> CodePushLocalPackage {
        let localPackage = CodePushLocalPackage()
        localPackage.appVersion = package.appVersion
        localPackage.deploymentKey = package.deploymentKey
        localPackage.description = package.description
        localPackage.failedInstall = failedInstall
        localPackage.isMandatory = package.isMandatory
        localPackage.label = package.label
        localPackage.packageHash = package.packageHash
        localPackage.isPending = pending
        localPackage.isFirstRun = firstRun
        localPackage.appEntryPoint = entryPoint
        return localPackage
    }
    
    static func createEmptyPackageForUpdateQuery(withVersion appVersion: String?) -> CodePushLocalPackage {
        let localPackage = CodePushLocalPackage()
        localPackage.appVersion = appVersion
        localPackage.failedInstall = false
        localPackage.isMandatory = false
        localPackage.isPending = false
        localPackage.isFirstRun = false
        return localPackage
    }
    
    override init() {
        super.init()
    }
}
