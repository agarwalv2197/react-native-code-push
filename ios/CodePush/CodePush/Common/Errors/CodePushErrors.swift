//
//  CodePushErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushErrors : Error {
    case CodePushAPI(cause: Error)
    case InvalidParam(cause: String)
    case IOErrors(cause: Error)
    case InitializationError(cause: String)
    case NoHashValue(cause: String)
    case MergeError(cause: String)
}
