//
//  CodePushLocalPackage.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Represents the downloaded package.
 */
public class CodePushLocalPackage: CodePushPackage {

    /**
     * Indicates whether this update is in a "pending" state.
     * When ```true```, that means the update has been downloaded and installed, but the app restart
     * needed to apply it hasn't occurred yet, and therefore, its changes aren't currently visible to the end-user.
     */
    public var isPending: Bool?

    /**
     * The path to the application entry point (e.g. android.js.bundle for RN, index.html for Cordova).
     */
    public var appEntryPoint: String?

    /**
     * Indicates whether this is the first time the update has been run after being installed.
     */
    public var isFirstRun: Bool?

    private enum CodingKeys: String, CodingKey {
        case isPending,
        appEntryPoint,
        isFirstRun
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        try super.init(from: superdecoder)

        self.isPending = try container.decode(Bool.self, forKey: .isPending)
        self.appEntryPoint = try container.decode(String.self, forKey: .appEntryPoint)
        self.isFirstRun = try container.decode(Bool.self, forKey: .isFirstRun)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isPending, forKey: .isPending)
        try container.encode(appEntryPoint, forKey: .appEntryPoint)
        try container.encode(isFirstRun, forKey: .isFirstRun)
        let superdecoder = container.superEncoder()
        try super.encode(to: superdecoder)
    }

    static func createLocalPackage(wasFailedInstall failedInstall: Bool,
                                   isFirstRun firstRun: Bool,
                                   isPending pending: Bool,
                                   withEntryPoint entryPoint: String,
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
