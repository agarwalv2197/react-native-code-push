//
//  CodePushPackageErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushPackageErrors: Error {    
    case FailedRollback
    case FailedInstall
    case FailedDownload
}
