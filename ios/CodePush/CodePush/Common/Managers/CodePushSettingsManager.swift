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
    init(_ codePushUtils: CodePushUtils, _ configuration: CodePushConfiguration?) {
        self.codePushUtils = codePushUtils
        self.codePushConfiguration = configuration
        self.settings = UserDefaults.standard
    }
    
    /**
     * Gets an array with containing failed updates info arranged by time of the failure ascending.
     * Each item represents an instance of {@link CodePushPackage} that has failed to update.
     *
     * @return an array of failed updates.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getFailedUpdates() throws -> [CodePushPackage]? {
        let failedUpdatesString: String = settings.string(forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)!
        if (failedUpdatesString.isEmpty) {
            return []
        }
        do {
            let failedUpdates: [CodePushPackage] = try codePushUtils.convertStringToObject(withString: failedUpdatesString)
            return failedUpdates
        } catch {
            let emptyArray = [CodePushPackage]()
            let failedString: String = try codePushUtils.convertObjectToJsonString(withObject: emptyArray)
            settings.set(failedString, forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
            return nil
        }
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
        } else {
            do {
                var update: CodePushPendingUpdate
                update = try codePushUtils.convertStringToObject(withString: pendingUpdateString!)
                return update

            } catch {
                print(error)
                return nil
            }
        }
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * @param packageHash hash to check.
     * @return <code>true</code> if there is a failed update with provided hash, <code>false</code> otherwise.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func existsFailedUpdate(withHash packageHash: String) throws -> Bool {
        let failedUpdates = try getFailedUpdates()
        if (!packageHash.isEmpty && failedUpdates != nil) {
            for failedPackage in failedUpdates! {
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
    func isPendingUpdate(withHash packageHash: String) throws -> Bool {
        let pendingUpdate = getPendingUpdate()
        return pendingUpdate != nil && !((pendingUpdate?.pendingUpdateIsLoading)!) &&
            (packageHash.isEmpty || pendingUpdate?.pendingUpdateHash == packageHash)
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
    func saveFailedUpdate(forPackage failedPackage: CodePushPackage) throws {
        var failedUpdates = try getFailedUpdates()
        failedUpdates?.append(failedPackage)
        let failedUpdatesString: String = try codePushUtils.convertObjectToJsonString(withObject: failedUpdates)
        settings.set(failedUpdatesString, forKey: getAppSpecificPrefix() + FAILED_UPDATES_KEY)
    }
    
    /**
     * Saves information about the pending update.
     *
     * @param pendingUpdate instance of the {@link CodePushPendingUpdate}.
     */
    func savePendingUpdate(forUpdate pendingUpdate: CodePushPendingUpdate) throws {
        let pendingUpdateString: String = try codePushUtils.convertObjectToJsonString(withObject: pendingUpdate)
        settings.set(pendingUpdateString, forKey: getAppSpecificPrefix() + PENDING_UPDATE_KEY)
    }
    
    /**
     * Returns app-specific prefix for preferences keys.
     *
     * @return preference key prefix to get app specific preferences
     */
    private func getAppSpecificPrefix() -> String {
        
        guard let appName = codePushConfiguration?.appName else {
            return ""
        }
        
        return appName + "-"
    }
}
