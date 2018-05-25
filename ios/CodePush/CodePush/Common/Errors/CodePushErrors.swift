//
//  CodePushErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

enum CodePushErrors: Error {
    case invalidParam(cause: String)
    case initialization(cause: String)
    case noHashValue(cause: String)
    case merge(cause: String)
    case unzip(cause: Error)
    case checkForUpdate(cause: Error)
    case sync(cause: Error)
    case download(cause: Error)
    case install(cause: String)
}
