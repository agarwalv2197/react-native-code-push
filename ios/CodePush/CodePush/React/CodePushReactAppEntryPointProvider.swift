//
//  CodePushReactAppEntryPointProvider.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * React-specific implementation of ```CodePushAppEntryPointProvider```.
 */
class CodePushReactAppEntryPointProvider: CodePushAppEntryPointProvider {

    /**
     * Path to the application entry point.
     */
    var appEntryPoint: String

    /**
     * Creates an instance of ```CodePushReactAppEntryPointProvider```.
     *
     * Parameter appEntryPoint path to the application entry point.
     */
    init(_ appEntryPoint: String) {
        self.appEntryPoint = appEntryPoint
    }

    func getAppEntryPoint() throws -> String {
        return !appEntryPoint.isEmpty ? appEntryPoint : CodePushReactNativeCore.DefaultJSBundleName
    }
}
