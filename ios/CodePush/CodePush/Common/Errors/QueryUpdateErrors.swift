//
//  QueryUpdateErrors.swift
//  CodePush
//
//  Created by Chris Moulds on 5/15/18.
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


enum QueryUpdateErrors: Error {
    case NoData
    case FailedJsonConversion
    case FailedToConstructUrl
}
