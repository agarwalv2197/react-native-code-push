//
//  CodePushSettingsManager.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushSettingsManager {
    
    /**
     * Instance of ```CodePushUtils``` to work with.
     */
    var codePushUtils: CodePushUtils
    
    /**
     * Instance of ```CodePushConfiguration``` to work with.
     */
    var codePushConfiguration: CodePushConfiguration?
    
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
     * Instance of ```UserDefaults```.
     */
    private var settings: UserDefaults
    
    /**
     * Creates an instance of ```CodePushSettingsManager```.
     *
     * Parameter codePushUtils      instance of ```CodePushUtils``` to work with.
     * Parameter configuration instance of ```CodePushConfiguration``` to work with.
     */
    init(_ codePushUtils: CodePushUtils, _ configuration: CodePushConfiguration?) {
        self.codePushUtils = codePushUtils
        self.codePushConfiguration = configuration
        self.settings = UserDefaults.standard
    }
    
    /**
     * Gets an array with containing failed updates info arranged by time of the failure ascending.
     * Each item represents an instance of ```CodePushPackage``` that has failed to update.
     *
     * Returns: an array of failed updates.
     * Throws: Error if the decoder fails to decode the failed update string
     */
    func getFailedUpdates() throws -> [CodePushPackage] {
        let failedUpdatesString: String? = settings.string(forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
        if (failedUpdatesString == nil || failedUpdatesString!.isEmpty) {
            return []
        }
        do {
            let failedUpdates: [CodePushPackage] = try codePushUtils.convertStringToObject(withString: failedUpdatesString!)
            return failedUpdates
        } catch {
            let emptyArray = [CodePushPackage]()
            let failedString: String = try codePushUtils.convertObjectToJsonString(withObject: emptyArray)
            settings.set(failedString, forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
            return []
        }
    }
    
    /**
     * Gets object with pending update info.
     *
     * Returns: object with pending update info or nil if there is no pending update
     * Throws: Error if
     */
    func getPendingUpdate() throws -> CodePushPendingUpdate? {
        let pendingUpdateString: String? = settings.string(forKey: getAppSpecificPrefix() + PENDING_UPDATE_KEY)
        if (pendingUpdateString == nil || pendingUpdateString!.isEmpty) {
            return nil
        } else {
            var update: CodePushPendingUpdate
            update = try codePushUtils.convertStringToObject(withString: pendingUpdateString!)
            return update
        }
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * Parameter packageHash hash to check.
     * Returns: ```true``` if there is a failed update with provided hash, ```false``` otherwise.
     * Throws: Error if fails to retrieve the failed updates
     */
    func existsFailedUpdate(withHash packageHash: String) throws -> Bool {
        let failedUpdates = try getFailedUpdates()
        if (!packageHash.isEmpty && !failedUpdates.isEmpty) {
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
     * Pass ```nil``` to check if there is any pending update.
     *
     * Parameter packageHash expected package hash of the pending update.
     * Returns: ```true``` if there is a pending update with the provided hash.
     * Throws: Error if fails to retrieve the pending update
     */
    func isPendingUpdate(withHash packageHash: String?) throws -> Bool {
        let pendingUpdate = try getPendingUpdate()
        return pendingUpdate != nil && !((pendingUpdate?.pendingUpdateIsLoading)!) &&
            (packageHash != nil && pendingUpdate?.pendingUpdateHash == packageHash)
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
     * Parameter failedPackage instance of failed ```CodePushRemotePackage```.
     * Throws: Error if fails to retrieve the existing failed updates or fails to encode them
     */
    func saveFailedUpdate(forPackage failedPackage: CodePushPackage) throws {
        var failedUpdates = try getFailedUpdates()
        failedUpdates.append(failedPackage)
        let failedUpdatesString: String = try codePushUtils.convertObjectToJsonString(withObject: failedUpdates)
        settings.set(failedUpdatesString, forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    }
    
    /**
     * Saves information about the pending update.
     *
     * Parameter pendingUpdate instance of the ```CodePushPendingUpdate```.
     * Throws: Error if fails to encode the pending update
     */
    func savePendingUpdate(forUpdate pendingUpdate: CodePushPendingUpdate) throws {
        let pendingUpdateString: String = try codePushUtils.convertObjectToJsonString(withObject: pendingUpdate)
        settings.set(pendingUpdateString, forKey: getAppSpecificPrefix() + PENDING_UPDATE_KEY)
    }
    
    /**
     * Returns app-specific prefix for preferences keys.
     *
     * Returns: preference key prefix to get app specific preferences
     */
    private func getAppSpecificPrefix() -> String {
        
        guard let appName = codePushConfiguration?.appName else {
            return ""
        }
        
        return appName + "-"
    }
}
