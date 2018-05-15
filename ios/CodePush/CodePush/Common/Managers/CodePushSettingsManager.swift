//
//  CodePushSettingsManager.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushSettingsManager {
    
    /**
     * Instance of {@link CodePushUtils} to work with.
     */
    var codePushUtils: CodePushUtils
    
    /**
     * Instance of {@link CodePushConfiguration} to work with.
     */
    var codePushConfiguration: CodePushConfiguration
    
    /**
     * Key for getting/storing info about failed CodePush updates.
     */
    private let FAILED_UPDATES_KEY = "CODE_PUSH_FAILED_UPDATES"
    
    /**
     * Key for getting/storing info about pending CodePush update.
     */
    private let PENDING_UPDATE_KEY = "CODE_PUSH_PENDING_UPDATE"
    
    /**
     * Key for storing last deployment report identifier.
     */
    private let LAST_DEPLOYMENT_REPORT_KEY = "CODE_PUSH_LAST_DEPLOYMENT_REPORT"
    
    /**
     * Key for storing last retry deployment report identifier.
     */
    private let RETRY_DEPLOYMENT_REPORT_KEY = "CODE_PUSH_RETRY_DEPLOYMENT_REPORT"
    
    /**
     * Instance of {@link UserDefaults}.
     */
    private var settings: UserDefaults
    
    /**
     * Creates an instance of {@link SettingsManager} with {@link Context} provided.
     *
     * @param applicationContext current application context.
     * @param codePushUtils      instance of {@link CodePushUtils} to work with.
     * @param codePushConfiguration instance of {@link CodePushConfiguration} to work with.
     */
    init(_ codePushUtils: CodePushUtils, codePushConfiguration: CodePushConfiguration) {
        self.codePushUtils = codePushUtils;
        self.codePushConfiguration = codePushConfiguration;
        self.settings = UserDefaults.standard
    }
    
    /**
     * Gets an array with containing failed updates info arranged by time of the failure ascending.
     * Each item represents an instance of {@link CodePushPackage} that has failed to update.
     *
     * @return an array of failed updates.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getFailedUpdates() -> Array<CodePushPackage> {
    let failedUpdatesString = settings.string(forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    if (failedUpdatesString == nil) {
        return []
    }
        
    return new ArrayList<>(Arrays.asList(codePushUtils.convertStringToObject(failedUpdatesString, CodePushPackage[].class)));
    
    var emptyArray = []
    settings.set(codePushUtils.convertObjectToJsonString(emptyArray), forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    }
    
    /**
     * Gets object with pending update info.
     *
     * @return object with pending update info.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getPendingUpdate() -> CodePushPendingUpdate? {
    let pendingUpdateString = settings.string(forKey: getAppSpecificPrefix() + PENDING_UPDATE_KEY)
    if (pendingUpdateString == nil) {
        return nil;
    }
   // try {
    return codePushUtils.convertStringToObject(pendingUpdateString, CodePushPendingUpdate.class);
//    } catch (JsonSyntaxException e) {
//    throw new CodePushMalformedDataException("Unable to parse pending update metadata " + pendingUpdateString + " stored in SharedPreferences", e);
//    }
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * @param packageHash hash to check.
     * @return <code>true</code> if there is a failed update with provided hash, <code>false</code> otherwise.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func existsFailedUpdate(withHash packageHash: String) -> Bool {
        let failedUpdates = getFailedUpdates()
        if (packageHash != nil) {
            for failedPackage in failedUpdates {
                if (packageHash == failedPackage.packageHash) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    /**
     * Checks whether there is a pending update with the provided hash.
     * Pass <code>null</code> to check if there is any pending update.
     *
     * @param packageHash expected package hash of the pending update.
     * @return <code>true</code> if there is a pending update with the provided hash.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func isPendingUpdate(withHash packageHash: String) -> Bool {
        CodePushPendingUpdate pendingUpdate = getPendingUpdate();
        return isPendingUpdate != nil && !pendingUpdate.isPendingUpdateLoading() &&
            (packageHash == nil || isPendingUpdate.getPendingUpdateHash() == packageHash)
    }
    
    /**
     * Removes information about failed updates.
     */
    func removeFailedUpdates() {
        settings.removeObject(forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    }
    
    /**
     * Removes information about the pending update.
     */
    func removePendingUpdate() {
        settings.removeObject(forKey: getAppSpecificPrefix() + PENDING_UPDATE_KEY)
    }
    
    /**
     * Adds another failed update info to the list of failed updates.
     *
     * @param failedPackage instance of failed {@link CodePushRemotePackage}.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func saveFailedUpdate(forPackage failedPackage: CodePushPackage) {
        var failedUpdates = getFailedUpdates()
        failedUpdates.append(failedPackage)
        let failedUpdatesString = codePushUtils.convertObjectToJsonString(failedUpdates);
        settings.set(failedUpdatesString, getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    }
    
    /**
     * Saves information about the pending update.
     *
     * @param pendingUpdate instance of the {@link CodePushPendingUpdate}.
     */
    func savePendingUpdate(forUpdate pendingUpdate: CodePushPendingUpdate) {
        let pendingUpdateString = codePushUtils.convertObjectToJsonString(pendingUpdate)
        settings.set(pendingUpdateString, getAppSpecificPrefix() + PENDING_UPDATE_KEY)
    }
    
    /**
     * Gets status report already saved for retry it's sending.
     *
     * @return report saved for retry sending.
     * @throws JSONException if there was error of deserialization of report from json document.
     */
    public CodePushDeploymentStatusReport getStatusReportSavedForRetry() throws JSONException {
    String retryStatusReportString = mSettings.getString(getAppSpecificPrefix() + RETRY_DEPLOYMENT_REPORT_KEY, null);
    if (retryStatusReportString != null) {
    JSONObject retryStatusReport = new JSONObject(retryStatusReportString);
    return mCodePushUtils.convertJsonObjectToObject(retryStatusReport, CodePushDeploymentStatusReport.class);
    }
    return null;
    }
    
    /**
     * Saves status report for further retry os it's sending.
     *
     * @param statusReport status report.
     * @throws JSONException if there was an error during report serialization into json document.
     */
    public void saveStatusReportForRetry(CodePushDeploymentStatusReport statusReport) throws JSONException {
    JSONObject statusReportJSON = mCodePushUtils.convertObjectToJsonObject(statusReport);
    mSettings.edit().putString(getAppSpecificPrefix() + RETRY_DEPLOYMENT_REPORT_KEY, statusReportJSON.toString()).apply();
    }
    
    /**
     * Remove status report that was saved for retry of it's sending.
     */
    public void removeStatusReportSavedForRetry() {
    mSettings.edit().remove(getAppSpecificPrefix() + RETRY_DEPLOYMENT_REPORT_KEY).apply();
    }
    
    /**
     * Gets previously saved status report identifier.
     *
     * @return previously saved status report identifier.
     */
    public CodePushStatusReportIdentifier getPreviousStatusReportIdentifier() {
    String identifierString = mSettings.getString(getAppSpecificPrefix() + LAST_DEPLOYMENT_REPORT_KEY, null);
    if (identifierString != null) {
    return CodePushStatusReportIdentifier.fromString(identifierString);
    }
    return null;
    }
    
    /**
     * Saves identifier of already sent status report.
     *
     * @param identifier identifier of already sent status report.
     */
    func saveIdentifierOfReportedStatus(CodePushStatusReportIdentifier identifier) {
    mSettings.edit().putString(getAppSpecificPrefix() + LAST_DEPLOYMENT_REPORT_KEY, identifier.toString()).apply();
    }
    
    /**
     * Returns app-specific prefix for preferences keys.
     *
     * @return preference key prefix to get app specific preferences
     */
    private func getAppSpecificPrefix() -> String? {
        return codePushConfiguration.appName != nil ? codePushConfiguration.appName! + "-" : ""
    }
}
