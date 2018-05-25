//
//  QueryUpdateErrors.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

enum QueryUpdateErrors: Error {
    case noData
    case failedJsonConversion
    case failedToConstructUrl
}
