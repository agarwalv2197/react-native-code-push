//
//  CodePushPackageErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

enum CodePushPackageErrors: Error {
    case failedRollback(cause: Error)
    case failedInstall(cause: Error)
    case failedDownload(cause: Error)
}
