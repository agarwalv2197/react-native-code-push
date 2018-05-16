//
//  CheckForUpdateTask.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class ApiRequest {
    
    private let URL: URL
    private let httpMethod: String
    var task: task_t?
    
    init(_ url: URL, _ httpMethod: String) {
        self.URL = url
        self.httpMethod = httpMethod
    }
    
    func checkForUpdate(completion: @escaping (Result<String>) -> Void) {
        var request = URLRequest(url: URL)
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
