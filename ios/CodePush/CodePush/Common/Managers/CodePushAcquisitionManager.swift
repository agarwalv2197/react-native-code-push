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
    private static let REPORT_DEPLOYMENT_STATUS_ENDPOINT = "reportStatus/deploy";
    
    /**
     * Query updates string pattern.
     */
    private static let UPDATE_CHECK_ENDPOINT = "updateCheck?%s";
    
    /**
     * Instance of {@link CodePushUtils} to work with.
     */
    private var codePushUtils: CodePushUtils;
    
    /**
     * Instance of {@link FileUtils} to work with.
     */
    private var fileUtils: FileUtils;
    
    init(_ codePushUtils: CodePushUtils, _ fileUtils: FileUtils) {
        self.codePushUtils = codePushUtils
        self.fileUtils = fileUtils
    }
    
    private func fixServerUrl(withUrl serverUrl: String) -> String {
        if (serverUrl.last != "/") {
            return serverUrl + "/"
        }
        return serverUrl
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
                                       withPackage currentPackage: CodePushLocalPackage) -> CodePushRemotePackage? {
//    if (currentPackage.appVersion == nil) {
//        throw new CodePushQueryUpdateException("Calling common acquisition SDK with incorrect package");
//    }
    
        /* Extract parameters from configuration */
        let serverUrl = fixServerUrl(withUrl: configuration.serverUrl!)
        let deploymentKey = configuration.deploymentKey
        let clientUniqueId = configuration.clientUniqueId
        
        let updateRequest = CodePushUpdateRequest.createUpdateRequest(withKey: deploymentKey!, withLocalPackage: currentPackage, withClientUniqueId: clientUniqueId!)
        
        let requestUrl = serverUrl + String.format(Locale.getDefault(), UPDATE_CHECK_ENDPOINT, codePushUtils.getQueryStringFromObject(updateRequest, "UTF-8"))
        
    CheckForUpdateTask checkForUpdateTask = new CheckForUpdateTask(mFileUtils, mCodePushUtils, requestUrl);
    ApiHttpRequest<CodePushUpdateResponse> checkForUpdateRequest = new ApiHttpRequest<>(checkForUpdateTask);
    try {
            let codePushUpdateResponse = checkForUpdateRequest.makeRequest();
        let updateInfo = codePushUpdateResponse.getUpdateInfo();
    if (updateInfo.isUpdateAppVersion()) {
    return CodePushRemotePackage.createDefaultRemotePackage(updateInfo.getAppVersion(), updateInfo.isUpdateAppVersion());
    } else if (!updateInfo.isAvailable()) {
    return null;
    }
    return CodePushRemotePackage.createRemotePackageFromUpdateInfo(deploymentKey, updateInfo);
    } catch (CodePushApiHttpRequestException e) {
    throw new CodePushQueryUpdateException(e, currentPackage.getPackageHash());
    }
    } catch (CodePushMalformedDataException | CodePushIllegalArgumentException e) {
    throw new CodePushQueryUpdateException(e, currentPackage.getPackageHash());
    }
    }

}
