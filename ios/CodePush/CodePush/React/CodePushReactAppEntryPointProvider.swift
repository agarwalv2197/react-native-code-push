//
//  CodePushReactAppEntryPointProvider.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushReactAppEntryPointProvider : CodePushAppEntryPointProvider {
    
    var appEntryPoint: String
    
    init(_ appEntryPoint: String) {
        self.appEntryPoint = appEntryPoint
    }
    
    func getAppEntryPoint() throws -> String {
        return !appEntryPoint.isEmpty ? appEntryPoint : CodePushReactNativeCore.DEFAULT_JS_BUNDLE_NAME
    }
}
