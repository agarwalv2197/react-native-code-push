//
//  CodePushBaseCore.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

public class CodePushBaseCore {
    
    var deploymentKey: String
    var baseDirectory: String?
    var serverUrl = "codepush.azurewebsites.net"
    var publicKey: String
    var appName: String?
    var appVersion: String?
    var state: CodePushState
    var utilities: CodePushUtilities
    var managers: CodePushManagers
    // TODO: var listeners: CodePushListeners
    
    /**
     * Creates instance of {@link CodePushBaseCore}. Default constructor.
     * We pass {@link Application} and app secret here, too, because we can't initialize AppCenter in another constructor and then call this.
     * However, AppCenter must be initialized before creating anything else.
     *
     * @param deploymentKey         deployment key.
     * @param context               application context.
     * @param application           application instance (pass <code>null</code> if you don't need {@link Crashes} integration for tracking exceptions).
     * @param appSecret             the value of app secret from AppCenter portal to configure {@link Crashes} sdk.
     *                              Pass <code>null</code> if you don't need {@link Crashes} integration for tracking exceptions.
     * @param isDebugMode           indicates whether application is running in debug mode.
     * @param baseDirectory         Base directory for CodePush files.
     * @param serverUrl             CodePush server url.
     * @param appName               application name.
     * @param appVersion            application version.
     * @param publicKeyProvider     instance of {@link CodePushPublicKeyProvider}.
     * @param appEntryPointProvider instance of {@link CodePushAppEntryPointProvider}.
     * @param platformUtils         instance of {@link CodePushPlatformUtils}.
     * @throws CodePushInitializeException error occurred during the initialization.
     */
    init(_ deploymentKey: String,
         _ appSecret: String,
         _ isDebugMode: Bool,
         _ baseDirectory: String,
         _ serverUrl: String,
         _ appName: String,
         _ appVersion: String,
         //CodePushPublicKeyProvider publicKeyProvider,
        //CodePushAppEntryPointProvider appEntryPointProvider,
        _ platformUtils: CodePushPlatformUtils) {
        
        /* Initialize configuration. */
        self.deploymentKey = deploymentKey
        self.baseDirectory = !baseDirectory.isEmpty ? baseDirectory : FileManager.default.currentDirectoryPath
        if (!serverUrl.isEmpty) {
            self.serverUrl = serverUrl
        }
        
        if (!appName.isEmpty) {
            self.appName = appName
        }
        
        if (!appVersion.isEmpty) {
            self.appVersion = appVersion
        } else {
            //    try {
            //    mPublicKey = publicKeyProvider.getPublicKey();
            //    PackageInfo pInfo = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
            //    mAppVersion = pInfo.versionName;
            //    } catch (PackageManager.NameNotFoundException | CodePushInvalidPublicKeyException e) {
            //    throw new CodePushInitializeException("Unable to get package info for " + mContext.getPackageName(), e);
            //    }
        }
        
        /* Initialize state */
        self.state = CodePushState()
        
        self.publicKey = ""
        
        /* Initialize utilities. */
        let fileUtils = FileUtils.sharedInstance;
        let utils = CodePushUtils.sharedInstance;
        let updateUtils = CodePushUpdateUtils.sharedInstance;
        self.utilities = CodePushUtilities(utils, fileUtils, updateUtils, platformUtils)
        
        let updateManager = CodePushUpdateManager(baseDirectory, platformUtils, fileUtils, utils, updateUtils, nil)
        let settingsManager = CodePushSettingsManager(utils, nil)
        //  CodePushTelemetryManager telemetryManager = new CodePushTelemetryManager(settingsManager);
        //  CodePushRestartManager restartManager = new CodePushRestartManager(new CodePushRestartHandler() {
        //    @Override
        //    public void performRestart(CodePushRestartListener codePushRestartListener, boolean onlyIfUpdateIsPending) throws CodePushMalformedDataException {
        //    restartInternal(codePushRestartListener, onlyIfUpdateIsPending);
        //    }
        //    });
        
        let acquisitionManager = CodePushAcquisitionManager(utilities.utils, utilities.fileUtils)
        self.managers = CodePushManagers(updateManager, acquisitionManager, settingsManager)
        
        /* Initialize managers. */
        let configuration = getNativeConfiguration()

        managers.updateManager.codePushConfiguration = configuration
        managers.settingsManager.codePushConfiguration = configuration
        /* Initializes listeners */
        // mListeners = new CodePushListeners();
        
        /* Initialize update after restart. */
        //initializeUpdateAfterRestart()
    }
    
    func checkForUpdate(callback completion: @escaping (Result<CodePushRemotePackage>) -> Void) {
        let configuration = getNativeConfiguration()
        return checkForUpdate(withKey: configuration.deploymentKey!, callback: completion)
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * @param packageHash hash to check.
     * @return <code>true</code> if there is a failed update with provided hash, <code>false</code> otherwise.
     */
    //    func existsFailedUpdate(fromHash packageHash: String) -> Bool {
    //        return managers.settingsManager.existsFailedUpdate(withHash: packageHash)
    //    }
    
    /**
     * Indicates whether update with specified packageHash is running for the first time.
     *
     * @param packageHash package hash for check.
     * @return true, if application is running for the first time, false otherwise.
     * @throws CodePushNativeApiCallException if error occurred during the operation.
     */
    //    func isFirstRun(fromHash packageHash: String) -> Bool {
    //        return state.didUpdate! && !packageHash.isEmpty &&
    //            packageHash == managers.updateManager.getCurrentPackageHash()
    //    }
    
    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified <code>updateState</code> parameter.
     *
     * @param updateState current update state.
     * @return installed update metadata.
     */
    //    func getUpdateMetadata(inState updateState: CodePushUpdateState) -> CodePushLocalPackage? {
    //
    //        let currentPackage = self.managers.updateManager.getCurrentPackage();
    //
    //        var currentUpdateIsPending = false
    //        var isDebugOnly = false
    //
    //        if ((currentPackage?.packageHash) != nil) {
    //            let currentHash = currentPackage?.packageHash
    //            currentUpdateIsPending = self.managers.settingsManager.isPendingUpdate(withHash: currentHash!)
    //
    //        }
    //        if (updateState == CodePushUpdateState.PENDING && !currentUpdateIsPending) {
    //            /* The caller wanted a pending update but there isn't currently one. */
    //            return nil;
    //        } else if (updateState == CodePushUpdateState.RUNNING && currentUpdateIsPending) {
    //
    //            /* The caller wants the running update, but the current one is pending, so we need to grab the previous. */
    //            let previousPackage = self.managers.updateManager.getPreviousPackage()
    //            if (previousPackage == nil) {
    //                return nil;
    //            } else{
    //                return previousPackage;
    //            }
    //        } else {
    //
    //            /*
    //             * The current package satisfies the request:
    //             * 1) Caller wanted a pending, and there is a pending update
    //             * 2) Caller wanted the running update, and there isn't a pending
    //             * 3) Caller wants the latest update, regardless if it's pending or not
    //             */
    //            if (state.isRunningBinaryVersion)! {
    //
    //                /*
    //                 * This only matters in Debug builds. Since we do not clear "outdated" updates,
    //                 * we need to indicate to the JS side that somehow we have a current update on
    //                 * disk that is not actually running.
    //                 */
    //                isDebugOnly = true;
    //            }
    //
    //            /* Enable differentiating pending vs. non-pending updates */
    //            let packageHash = currentPackage?.packageHash
    //            currentPackage?.failedInstall = existsFailedUpdate(fromHash: packageHash!)
    //            currentPackage?.isFirstRun = isFirstRun(fromHash: packageHash!)
    //            currentPackage?.isPending = currentUpdateIsPending
    //            return currentPackage;
    //        }
    //    }
    
    /**
     * Gets native CodePush configuration.
     *
     * @return native CodePush configuration.
     */
    func getNativeConfiguration() -> CodePushConfiguration {
        
        let config = CodePushConfiguration()
        config.appName = self.appName != nil ? self.appName : CodePushConstants.CODE_PUSH_DEFAULT_APP_NAME
        config.appVersion = self.appVersion
        config.clientUniqueId = "testDevice"//UIDevice.current.identifierForVendor!.uuidString
        config.deploymentKey = self.deploymentKey
        config.baseDirectory = self.baseDirectory
        config.serverUrl = self.serverUrl
        //config.packageHash = utilities.updateUtils.getHashForBinaryContents()
        return config
    }
    
    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using specified deployment key.
     *
     * @param deploymentKey deployment key to use.
     * @return remote package info if there is an update, <code>null</code> otherwise.
     * @throws CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func checkForUpdate(withKey deploymentKey: String, callback completion: @escaping (Result<CodePushRemotePackage>) -> Void) {
        let config = getNativeConfiguration()
        config.deploymentKey = !deploymentKey.isEmpty ? deploymentKey : config.deploymentKey
        
        //        let localPackage = getUpdateMetadata(inState: CodePushUpdateState.LATEST)
        //        var queryPackage : CodePushLocalPackage
        //        if (localPackage == nil) {
        let queryPackage = CodePushLocalPackage.createEmptyPackageForUpdateQuery(withVersion: config.appVersion)
        CodePushAcquisitionManager(utilities.utils, utilities.fileUtils).queryUpdate(withConfig: config, withPackage: queryPackage,
                                                                                                callback: completion)
    }
    
    /**
     * Initializes update after app restart.
     *
     * @throws CodePushGetPackageException    if error occurred during the getting current package.
     * @throws CodePushPlatformUtilsException if error occurred during usage of {@link CodePushPlatformUtils}.
     * @throws CodePushRollbackException      if error occurred during rolling back of package.
     */
    //    func initializeUpdateAfterRestart() {
    //
    //        /* Reset the state which indicates that the app was just freshly updated. */
    //        state.didUpdate = false
    //
    //        let pendingUpdate = managers.settingsManager.getPendingUpdate()
    //        if (pendingUpdate != nil) {
    //            let packageMetadata = managers.updateManager.getCurrentPackage()
    //            if (packageMetadata == nil || !utilities.platformUtils.isPackageLatest(packageMetadata!, appVersion!) &&
    //                    appVersion != packageMetadata?.appVersion) {
    //                // AppCenterLog.info(LOG_TAG, "Skipping initializeUpdateAfterRestart(), binary version is newer.");
    //                return
    //            }
    //            let updateIsLoading = pendingUpdate?.pendingUpdateIsLoading
    //            if (updateIsLoading!) {
    //
    //            /* Pending update was initialized, but notifyApplicationReady was not called.
    //             * Therefore, deduce that it is a broken update and rollback. */
    //            //AppCenterLog.info(LOG_TAG, "Update did not finish loading the last time, rolling back to a previous version.")
    //            state.needToReportRollback = true
    //            rollbackPackage()
    //            } else {
    //
    //                /* There is in fact a new update running for the first
    //                 * time, so update the local state to ensure the client knows. */
    //                state.didUpdate = true;
    //
    //                /* Mark that we tried to initialize the new update, so that if it crashes,
    //                 * we will know that we need to rollback when the app next starts. */
    //                managers.settingsManager.savePendingUpdate(forUpdate: pendingUpdate!);
    //            }
    //        }
    //    }
    
    /**
     * Rolls back package.
     *
     * @throws CodePushGetPackageException if error occurred during getting current update.
     * @throws CodePushRollbackException   if error occurred during rolling back of package.
     * @throws CodePushMalformedDataException
     */
    //    func rollbackPackage() {
    //        let failedPackage = managers.updateManager.getCurrentPackage()
    //        managers.settingsManager.saveFailedUpdate(forPackage: failedPackage!)
    //        managers.updateManager.rollbackPackage()
    //        managers.settingsManager.removePendingUpdate()
    //    }
}
