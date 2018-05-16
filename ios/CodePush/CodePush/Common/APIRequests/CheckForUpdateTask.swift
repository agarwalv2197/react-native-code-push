//
//  CheckForUpdateTask.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CheckForUpdateTask {
    
    static func checkForUpdate(atUrl url: URL, completion: @escaping (Result<String>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(Result {
                    if let error = error { throw error }
                    guard let data = data else { throw QueryUpdateErrors.NoData }
                    guard let json = String(data: data, encoding: .utf8) else { throw QueryUpdateErrors.FailedJsonConversion }
                    return json
                })
            }
        }
        
        task.resume()
    }
}
