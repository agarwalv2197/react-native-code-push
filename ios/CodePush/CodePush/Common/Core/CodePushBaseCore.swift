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
    var appEntryPoint: String
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
        self.appEntryPoint = CodePushConstants.DEFAULT_JS_BUNDLE_NAME
        
        /* Initialize utilities. */
        let fileUtils = FileUtils.sharedInstance;
        let utils = CodePushUtils.sharedInstance;
        let updateUtils = CodePushUpdateUtils.sharedInstance;
        self.utilities = CodePushUtilities(utils, fileUtils, updateUtils, platformUtils)
        
        self.baseDirectory = !baseDirectory.isEmpty ? baseDirectory : self.utilities.fileUtils.appendPathComponent(atBasePath: FileManager.default.currentDirectoryPath, withComponent: CodePushConstants.CODE_PUSH_FOLDER_PREFIX)
        
        let updateManager = CodePushUpdateManager(self.baseDirectory!, platformUtils, fileUtils, utils, updateUtils, nil)
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
        do {
            let localPackage = try getUpdateMetadata(inUpdateState: .LATEST)
            let queryPackage = localPackage != nil ? localPackage : CodePushLocalPackage.createEmptyPackageForUpdateQuery(withVersion: config.appVersion)
            CodePushAcquisitionManager(utilities.utils, utilities.fileUtils).queryUpdate(withConfig: config, withPackage: queryPackage!,
                                                                                         callback: completion)
        } catch {
            completion(Result { throw QueryUpdateErrors.FailedToConstructUrl })
        }
    }
    
    /**
     * Synchronizes your app assets with the latest release to the configured deployment.
     *
     * @param synchronizationOptions sync options.
     * @throws CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func sync(withOptions syncOptions: CodePushSyncOptions) {
        //        if (state.syncInProgress) {
        //            notifyAboutSyncStatusChange(SYNC_IN_PROGRESS);
        //            AppCenterLog.info(CodePush.LOG_TAG, "Sync already in progress.");
        //            return;
        //        }
        
        if (syncOptions.deploymentKey.isEmpty) {
            syncOptions.deploymentKey = deploymentKey
        }
        if (syncOptions.installMode == nil) {
            syncOptions.installMode = CodePushInstallMode.ON_NEXT_RESTART
        }
        if (syncOptions.mandatoryInstallMode == nil) {
            syncOptions.mandatoryInstallMode = CodePushInstallMode.IMMEDIATE
        }
        
        /* minimumBackgroundDuration, ignoreFailedUpdates are primitives and always have default value */
        if (syncOptions.checkFrequency == nil) {
            syncOptions.checkFrequency = CodePushCheckFrequency.ON_APP_START
        }
        let configuration = getNativeConfiguration()
        
        if (!syncOptions.deploymentKey.isEmpty) {
            configuration.deploymentKey = syncOptions.deploymentKey
        }
        // state.syncInProgress = true
        //    try {
        //notifyAboutSyncStatusChange(CHECKING_FOR_UPDATE);
        //        checkForUpdate(withKey: syncOptions.deploymentKey, callback: { result in
        //            do {
        //                let remotePackage = try result.resolve()
        //                self.doDownloadAndInstall(package: remotePackage, withOptions: syncOptions, withConfig: configuration, callback: { result in
        //                    do {
        //                        let success = try result.resolve()
        //                    } catch { print(error) }
        //
        //                })
        //            } catch {
        //                print(error)
        //            }
        //        });
        //
        
        
        
        let basePackage = CodePushPackage()
        basePackage.deploymentKey = "i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf"
        basePackage.packageHash = "12f376f76b1bfd68103aaa1db84ba5ea7284951e0af02aff33bf7aa880d9ec51"
        basePackage.label = "v14"
        basePackage.isMandatory = false
        basePackage.failedInstall = false
        basePackage.description = "version 1.0.8 working"
        let remotePackage = CodePushRemotePackage.createRemotePackage(fromFailedInstall: false, size: 186598, atUrl: "https://codepush.blob.core.windows.net/storagev2/0GqmGWPkR6xVG8SvaF8QN3wLmbWE12058267-11c6-40ff-b975-6397a0cb8e3e", updateVersion: false, fromPackage: basePackage)
        
        self.doDownloadAndInstall(package: remotePackage, withOptions: syncOptions, withConfig: configuration, callback: { result in
            do {
                let success = try result.resolve()
            } catch { print(error) }
            
        })
        
        //        final boolean updateShouldBeIgnored =
        //        remotePackage != null && (remotePackage.isFailedInstall() && syncOptions.getIgnoreFailedUpdates());
        //        if (remotePackage == null || updateShouldBeIgnored) {
        //        if (updateShouldBeIgnored) {
        //        AppCenterLog.info(CodePush.LOG_TAG, "An update is available, but it is being ignored due to having been previously rolled back.");
        //        }
        //        CodePushLocalPackage currentPackage = getCurrentPackage();
        //        if (currentPackage != null && currentPackage.isPending()) {
        //        notifyAboutSyncStatusChange(UPDATE_INSTALLED);
        //        } else {
        //        notifyAboutSyncStatusChange(UP_TO_DATE);
        //        }
        //        mState.mSyncInProgress = false;
        //        } else if (syncOptions.getUpdateDialog() != null) {
        //        final CodePushUpdateDialog updateDialogOptions = syncOptions.getUpdateDialog();
        //        String message;
        //        final String acceptButtonText;
        //        final String declineButtonText = updateDialogOptions.getOptionalIgnoreButtonLabel();
        //        if (remotePackage.isMandatory()) {
        //        message = updateDialogOptions.getMandatoryUpdateMessage();
        //        acceptButtonText = updateDialogOptions.getMandatoryContinueButtonLabel();
        //        } else {
        //        message = updateDialogOptions.getOptionalUpdateMessage();
        //        acceptButtonText = updateDialogOptions.getOptionalInstallButtonLabel();
        //        }
        //        if (updateDialogOptions.getAppendReleaseDescription() && !isEmpty(remotePackage.getDescription())) {
        //        message = updateDialogOptions.getDescriptionPrefix() + " " + remotePackage.getDescription();
        //        }
        
        /* Ask user whether he want to install update or ignore it. */
        //        notifyAboutSyncStatusChange(AWAITING_USER_ACTION);
        //        final String finalMessage = message;
        //        new Handler(Looper.getMainLooper()).post(new Runnable() {
        //        @Override
        //        public void run() {
        //        mConfirmationDialog.shouldInstallUpdate(updateDialogOptions.getTitle(), finalMessage, acceptButtonText, declineButtonText, new CodePushConfirmationCallback() {
        //
        //        @Override
        //        public void onResult(boolean userAcceptsProposal) {
        //        if (userAcceptsProposal) {
        //        try {
        //           doDownloadAndInstall(remotePackage, syncOptions, configuration)
        // state.syncInProgress = false
        //        } catch (Exception e) {
        //        notifyAboutSyncStatusChange(UNKNOWN_ERROR);
        //        mState.mSyncInProgress = false;
        //        CodePushLogUtils.trackException(new CodePushNativeApiCallException(e));
        //        }
        //        } else {
        //        notifyAboutSyncStatusChange(UPDATE_IGNORED);
        //        mState.mSyncInProgress = false;
        //        }
        //        }
        
        //   @Override
        //        public void throwError(CodePushGeneralException e) {
        //        notifyAboutSyncStatusChange(UNKNOWN_ERROR)
        //        state.syncInProgress = false
        //        CodePushLogUtils.trackException(new CodePushNativeApiCallException(e));
        //        }
        //        });
        //        }
        //        });
        //        } else {
        //        doDownloadAndInstall(remotePackage, syncOptions, configuration);
        //        mState.mSyncInProgress = false;
        //        }
        //        } catch (Exception e) {
        //        notifyAboutSyncStatusChange(UNKNOWN_ERROR);
        //        mState.mSyncInProgress = false;
        //        throw new CodePushNativeApiCallException(e);
        //        }
    }
    
    /**
     * Downloads and installs update.
     *
     * @param remotePackage update to use.
     * @param syncOptions   sync options.
     * @param configuration configuration to use.
     * @throws CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func doDownloadAndInstall(package remotePackage: CodePushRemotePackage, withOptions syncOptions: CodePushSyncOptions,
                              withConfig configuration: CodePushConfiguration,
                              callback completion: @escaping (Result<Bool>) -> Void) {
        // notifyAboutSyncStatusChange(DOWNLOADING_PACKAGE)
        downloadUpdate(package: remotePackage, callback: { result in
            do {
                completion (Result{
                    let localPackage = try result.resolve()
                    if localPackage != nil {
                        return true
                    } else {
                        return false
                    }
                })
            }
        })
        
        //    try {
        //        mManagers.mAcquisitionManager.reportStatusDownload(configuration, localPackage);
        //    } catch (CodePushReportStatusException e) {
        //        CodePushLogUtils.trackException(e);
        //    }
        //    let resolvedInstallMode = localPackage.isMandatory ? syncOptions.mandatoryInstallMode : syncOptions.installMode
        //    state.currentInstallModeInProgress = resolvedInstallMode;
        //    notifyAboutSyncStatusChange(CodePushSyncStatus.INSTALLING_UPDATE);
        //    installUpdate(localPackage, resolvedInstallMode, syncOptions.getMinimumBackgroundDuration());
        //    notifyAboutSyncStatusChange(UPDATE_INSTALLED);
        //    mState.mSyncInProgress = false;
        //    if (resolvedInstallMode == IMMEDIATE) {
        //        try {
        //        mManagers.mRestartManager.restartApp(false);
        //        } catch (CodePushMalformedDataException e) {
        //        throw new CodePushNativeApiCallException(e);
        //        }
        //    } else {
        //        mManagers.mRestartManager.clearPendingRestart();
        //    }
    }
    
    /**
     * Downloads update.
     *
     * @param updatePackage update to download.
     * @return resulted local package.
     * @throws CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func downloadUpdate(package updatePackage: CodePushRemotePackage,
                        callback completion: @escaping (Result<CodePushLocalPackage>) -> Void) {
        do {
            
            //let binaryModifiedTime = "" + utilities.platformUtils.getBinaryResourcesModifiedTime(mContext)
            let downloadUrl = updatePackage.downloadURL
            
            managers.updateManager
                .downloadPackage(withHash: updatePackage.packageHash!, atUrl: downloadUrl!,
                                 callback: { result in
                                    completion ( Result {
                                        do {
                                            let package = try result.resolve()
                                            //                let isZip = downloadPackageResult.isZip
                                            let newUpdateFolderPath = self.managers.updateManager.getPackageFolderPath(withHash: updatePackage.packageHash!)
                                            
                                            try self.utilities.fileUtils.createDirectoryIfNotExists(path: newUpdateFolderPath)
                                            
                                            let newUpdateMetadataPath = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath, withComponent: CodePushConstants.PACKAGE_FILE_NAME)
                                            let newUpdateFilePath = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath, withComponent: self.appEntryPoint)
                                            // var appEntryPoint: String
                                            //                                                            if (isZip) {
                                            //                                                                managers.updateManager.unzipPackage(downloadFile)
                                            //                                                                appEntryPoint = managers.updateManager.mergeDiff(newUpdateFolderPath, newUpdateMetadataPath, updatePackage.packageHash, publicKey, appEntryPoint)
                                            //                                                            } else {
                                            
                                            try self.utilities.fileUtils.moveFile(file: package.downloadFile, toDestination: newUpdateFilePath)
                                            //                                                            }
                                            let newPackage = CodePushLocalPackage.createLocalPackage(wasFailedInstall: false, isFirstRun: false, isPending: false,
                                                                                                     isDebugOnly: true, withEntryPoint: self.appEntryPoint, fromPackage: updatePackage)
                                            // newPackage.binaryModifiedTime = binaryModifiedTime
                                            
                                            try self.utilities.utils.writeObjectToJsonFile(withObject: newPackage, atPath: newUpdateMetadataPath)
                                            return newPackage
                                        } catch {
                                            // try self.managers.settingsManager.saveFailedUpdate(forPackage: updatePackage)
                                            throw error
                                        }
                                    })
                } )
            
        }
    }
    
    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified <code>updateState</code> parameter.
     *
     * @param updateState current update state.
     * @return installed update metadata.
     * @throws CodePushNativeApiCallException if error occurred during the operation.
     */
    func getUpdateMetadata(inUpdateState updateState: CodePushUpdateState) throws -> CodePushLocalPackage? {
        
        let currentPackage = managers.updateManager.getCurrentPackage()
        
        if (currentPackage == nil) {
            return nil
        }
        var currentUpdateIsPending = false
        var isDebugOnly = false
        if (!(currentPackage?.packageHash?.isEmpty)!) {
            let currentHash = currentPackage?.packageHash
           // currentUpdateIsPending = managers.settingsManager.isPendingUpdate(currentHash)
        }
        if (updateState == .PENDING && !currentUpdateIsPending) {
            
            /* The caller wanted a pending update but there isn't currently one. */
            return nil
        } else if (updateState == .RUNNING && currentUpdateIsPending) {
            
            /* The caller wants the running update, but the current one is pending, so we need to grab the previous. */
            var previousPackage: CodePushLocalPackage

            do {
                previousPackage = (try managers.updateManager.getPreviousPackage())!
            } catch {
                return nil
            }

            return previousPackage
        } else {
            
            /*
             * The current package satisfies the request:
             * 1) Caller wanted a pending, and there is a pending update
             * 2) Caller wanted the running update, and there isn't a pending
             * 3) Caller wants the latest update, regardless if it's pending or not
             */
            if (state.isRunningBinaryVersion)! {
                
                /*
                 * This only matters in Debug builds. Since we do not clear "outdated" updates,
                 * we need to indicate to the JS side that somehow we have a current update on
                 * disk that is not actually running.
                 */
                isDebugOnly = true
            }
            
            /* Enable differentiating pending vs. non-pending updates */
            let packageHash = currentPackage?.packageHash
//            currentPackage.failedInstall = existsFailedUpdate(packageHash)
//            currentPackage.firstRun = isFirstRun(packageHash)
            currentPackage?.isPending = currentUpdateIsPending
            currentPackage?.isDebugOnly = isDebugOnly
            return currentPackage
        }
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
