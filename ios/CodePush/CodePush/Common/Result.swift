//
//  Result.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure(Error)
}

extension Result {
    
    // Return the value if it's a .Success or throw the error if it's a .Failure
    func resolve() throws -> T {
        switch self {
        case Result.Success(let value): return value
        case Result.Failure(let error): throw error
        }
    }
    
    // Construct a .Success if the expression returns a value or a .Failure if it throws
    init(_ throwingExpr: () throws -> T) {
        do {
            let value = try throwingExpr()
            self = Result.Success(value)
        } catch {
            self = Result.Failure(error)
        }
    }
}
