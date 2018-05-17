//
//  CodePushAcquisitionManager.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushAcquisitionManager {
    
    /**
     * Endpoint for sending {@link CodePushDownloadStatusReport}.
     */
    private static let REPORT_DOWNLOAD_STATUS_ENDPOINT = "reportStatus/download"
    
    /**
     * Endpoint for sending {@link CodePushDeploymentStatusReport}.
     */
    private static let REPORT_DEPLOYMENT_STATUS_ENDPOINT = "reportStatus/deploy"
    
    /**
     * Query updates string pattern.
     */
    private static let UPDATE_CHECK_ENDPOINT = "/updateCheck"
    
    /**
     * Protocol
     */
    private static let SCHEME = "https"
    
    /**
     * Instance of {@link CodePushUtils} to work with.
     */
    private var codePushUtils: CodePushUtils
    
    /**
     * Instance of {@link FileUtils} to work with.
     */
    private var fileUtils: FileUtils
    
    init(_ codePushUtils: CodePushUtils, _ fileUtils: FileUtils) {
        self.codePushUtils = codePushUtils
        self.fileUtils = fileUtils
    }
    
    /**
     * Sends a request to server for updates of the current package.
     *
     * @param configuration  current application configuration.
     * @param currentPackage instance of {@link CodePushLocalPackage}.
     * @return {@link CodePushRemotePackage} or <code>null</code> if there is no update.
     * @throws CodePushQueryUpdateException exception occurred during querying for update.
     */
    func queryUpdate(withConfig configuration: CodePushConfiguration,
                     withPackage currentPackage: CodePushLocalPackage,
                     callback completion: @escaping (Result<CodePushRemotePackage>) -> Void) {
        
        guard currentPackage.appVersion != nil else { completion(Result { throw CodePushErrors.InvalidParam }); return }
        
        let updateRequest = CodePushUpdateRequest.createUpdateRequest(withKey: configuration.deploymentKey!, withLocalPackage: currentPackage, withClientUniqueId: configuration.clientUniqueId!)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = CodePushAcquisitionManager.SCHEME
        urlComponents.host = configuration.serverUrl
        urlComponents.path = CodePushAcquisitionManager.UPDATE_CHECK_ENDPOINT
        urlComponents.queryItems = codePushUtils.getQueryItems(fromObject: updateRequest)
        
        guard let url = urlComponents.url else { completion(Result { throw QueryUpdateErrors.FailedToConstructUrl }); return }
        
        let api = ApiRequest(url)
        
        api.checkForUpdate(completion: { result in
            completion( Result {
                let json = try result.resolve()
                let result: CodePushUpdateResponse = try self.codePushUtils.convertStringToObject(withString: json)
                let updateInfo = result.updateInfo
                if (updateInfo.updateAppVersion)! {
                    return CodePushRemotePackage.createDefaultRemotePackage(withVersion: updateInfo.appVersion!, updateVersion: updateInfo.updateAppVersion!)
                } else if (!updateInfo.isAvailable!) {
                    throw QueryUpdateErrors.NoData
                }
                return CodePushRemotePackage.createRemotePackage(withDeploymentKey: configuration.deploymentKey!, fromUpdateInfo: updateInfo)
            })
        })
    }
}
