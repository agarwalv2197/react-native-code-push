//
//  CodePushAcquisitionManager.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushAcquisitionManager {
    
    /**
     * Query updates endpoint.
     */
    private static let UpdateCheckEndpoint = "/updateCheck"

    /**
     * Protocol
     */
    private static let Scheme = "https"

    /**
     * Instance of ```CodePushUtils``` to work with.
     */
    private var codePushUtils: CodePushUtils

    /**
     * Instance of ```FileUtils``` to work with.
     */
    private var fileUtils: FileUtils

    init(_ codePushUtils: CodePushUtils, _ fileUtils: FileUtils) {
        self.codePushUtils = codePushUtils
        self.fileUtils = fileUtils
    }

    /**
     * Sends a request to server for updates of the current package.
     *
     * Parameter configuration  current application configuration.
     * Parameter currentPackage instance of ```CodePushLocalPackage```.
     * Returns: ```CodePushRemotePackage``` or ```nil``` if there is no update.
     * Throws: CodePushQueryUpdateException exception occurred during querying for update.
     */
    func queryUpdate(withConfig configuration: CodePushConfiguration,
                     withPackage currentPackage: CodePushLocalPackage,
                     callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {

        guard currentPackage.appVersion != nil else {
            completion(Result {
                throw CodePushErrors.invalidParam(cause: "Cannot query for an update without the app version")
            })
            return
        }

        let updateRequest = CodePushUpdateRequest.createUpdateRequest(withKey: configuration.deploymentKey!,
                                                                      withLocalPackage: currentPackage,
                                                                      withClientUniqueId: configuration.clientUniqueId!)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = CodePushAcquisitionManager.Scheme
        urlComponents.host = configuration.serverUrl
        urlComponents.path = CodePushAcquisitionManager.UpdateCheckEndpoint
        urlComponents.queryItems = codePushUtils.getQueryItems(fromObject: updateRequest)

        guard let url = urlComponents.url else {
            completion(Result { throw QueryUpdateErrors.failedToConstructUrl })
            return
        }

        let query = ApiRequest(url)

        query.checkForUpdate(completion: { result in
            completion( Result {
                let json = try result.resolve()
                let result: CodePushUpdateResponse = try self.codePushUtils.convertStringToObject(withString: json)
                let updateInfo = result.updateInfo
                if (updateInfo.updateAppVersion)! {
                    return CodePushRemotePackage.createDefaultRemotePackage(withVersion: updateInfo.appVersion!,
                                                                            updateVersion: updateInfo.updateAppVersion!)
                } else if !updateInfo.isAvailable! {
                    return nil
                }
                return CodePushRemotePackage.createRemotePackage(withDeploymentKey: configuration.deploymentKey!,
                                                                 fromUpdateInfo: updateInfo)
            })
        })
    }
}
