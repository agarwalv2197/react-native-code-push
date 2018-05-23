//
//  CheckForUpdateTask.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * HTTP tasks required for updates and syncing
 */
class ApiRequest {
    
    private let URL: URL
    
    init(_ url: URL) {
        self.URL = url
    }
    
    /**
     * Performs a GET at the specified URL
     * Parameter completion: the completion handler
     * Returns: the JSON response
     */
    func checkForUpdate(completion: @escaping (Result<String>) -> Void) {
        let session = URLSession.shared
        let request = getRequest()
        
        let task = session.dataTask(with: request) { (data, response, error) in
            session.invalidateAndCancel()
            completion(Result {
                if let error = error { throw error }
                guard let data = data else { throw QueryUpdateErrors.NoData }
                guard let json = String(data: data, encoding: .utf8) else { throw QueryUpdateErrors.FailedJsonConversion }
                return json
            })
        }
        
        task.resume()
    }
    
    /**
     * Instantiates a downloadTask at the specified URL
     * Parameter completion: the completion handler
     * Returns: the file path of the download
     */
    func downloadUpdate(completion: @escaping (Result<URL>) -> Void) {
        let session = URLSession.shared
        let request = getRequest()
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            session.invalidateAndCancel()
            completion (Result {
                if let tempLocalUrl = tempLocalUrl, error == nil {
                  return tempLocalUrl
                } else {
                    throw error!
                }
            })
        }
        
        task.resume()
    }
    
    private func getRequest() -> URLRequest {
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        return request
    }
}
