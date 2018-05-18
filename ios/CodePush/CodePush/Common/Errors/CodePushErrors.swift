//
//  CodePushErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum CodePushErrors : Error {
    case InvalidParam
    case IOErrors
    case NoHashValue
    case InitializationError
}
