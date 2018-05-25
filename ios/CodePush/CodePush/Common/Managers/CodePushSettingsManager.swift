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
    private let failedUpdatesKey = "CodePushFailedUpdates"

    /**
     * Key for getting/storing info about pending CodePush update.
     */
    private let pendingUpdateKey = "CodePushPendingUpdate"

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
        let failedUpdatesString: String? = settings.string(forKey: getAppSpecificPrefix() + failedUpdatesKey)
        if failedUpdatesString == nil || failedUpdatesString!.isEmpty {
            return []
        }
        do {
            let failedUpdates: [CodePushPackage] =
                try codePushUtils.convertStringToObject(withString: failedUpdatesString!)
            return failedUpdates
        } catch {
            let emptyArray = [CodePushPackage]()
            let failedString: String = try codePushUtils.convertObjectToJsonString(withObject: emptyArray)
            settings.set(failedString, forKey: getAppSpecificPrefix() + failedUpdatesKey)
            return []
        }
    }

    /**
     * Gets object with pending update info.
     *
     * Returns: object with pending update info or nil if there is no pending update
     * Throws: Error if fails to decode the pending update
     */
    func getPendingUpdate() throws -> CodePushPendingUpdate? {
        let pendingUpdateString: String? = settings.string(forKey: getAppSpecificPrefix() + pendingUpdateKey)
        if pendingUpdateString == nil || pendingUpdateString!.isEmpty {
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
        if !packageHash.isEmpty && !failedUpdates.isEmpty {
            for failedPackage in failedUpdates where packageHash == failedPackage.packageHash {
                return true
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
        settings.removeObject(forKey: getAppSpecificPrefix() + failedUpdatesKey)
    }

    /**
     * Removes information about the pending update.
     */
    func removePendingUpdate() {
        settings.removeObject(forKey: getAppSpecificPrefix() + pendingUpdateKey)
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
        settings.set(failedUpdatesString, forKey: getAppSpecificPrefix() + failedUpdatesKey)
    }

    /**
     * Saves information about the pending update.
     *
     * Parameter pendingUpdate instance of the ```CodePushPendingUpdate```.
     * Throws: Error if fails to encode the pending update
     */
    func savePendingUpdate(forUpdate pendingUpdate: CodePushPendingUpdate) throws {
        let pendingUpdateString: String = try codePushUtils.convertObjectToJsonString(withObject: pendingUpdate)
        settings.set(pendingUpdateString, forKey: getAppSpecificPrefix() + pendingUpdateKey)
    }

    /**
     * Returns app-specific prefix for preferences keys.
     *
     * Returns: preference key prefix to get app specific preferences
     */
    private func getAppSpecificPrefix() -> String {
        guard let appName = codePushConfiguration?.appName else { return "" }
        return appName + "-"
    }
}
