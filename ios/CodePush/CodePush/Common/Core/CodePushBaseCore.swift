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
    var serverUrl = "https://codepush.azurewebsites.net/"
    var publicKey: String
    var appName: String?
    var appVersion: String?
    var state: CodePushState?
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
    //TODO self.baseDirectory = baseDirectory != nil ? baseDirectory : mContext.getFilesDir().getAbsolutePath();
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
    
    /* Initialize utilities. */
    let fileUtils = FileUtils.sharedInstance;
    let utils = CodePushUtils.sharedInstance;
    let updateUtils = CodePushUpdateUtils.sharedInstance;
    self.utilities = CodePushUtilities(utils, fileUtils, updateUtils, platformUtils);
    
    /* Initialize managers. */
    let configuration = getNativeConfiguration();
        
    let updateManager = CodePushUpdateManager(baseDirectory, platformUtils, fileUtils, utils, updateUtils, configuration)
    let settingsManager = CodePushSettingsManager(utils, codePushConfiguration: configuration)
  //  CodePushTelemetryManager telemetryManager = new CodePushTelemetryManager(settingsManager);
  //  CodePushRestartManager restartManager = new CodePushRestartManager(new CodePushRestartHandler() {
//    @Override
//    public void performRestart(CodePushRestartListener codePushRestartListener, boolean onlyIfUpdateIsPending) throws CodePushMalformedDataException {
//    restartInternal(codePushRestartListener, onlyIfUpdateIsPending);
//    }
//    });
    
        let acquisitionManager = CodePushAcquisitionManager(utils, fileUtils)
        self.managers = CodePushManagers(updateManager, acquisitionManager)
    
    /* Initializes listeners */
   // mListeners = new CodePushListeners();
    
    /* Initialize state */
    self.state = CodePushState()
    
    /* Clear debug cache if needed. */
    if (mIsDebugMode && mManagers.mSettingsManager.isPendingUpdate(null)) {
    mUtilities.mPlatformUtils.clearDebugCache(mContext);
        }
    /* Initialize update after restart. */
    initializeUpdateAfterRestart();
    }
    
    func checkForUpdate() -> CodePushRemotePackage {
        let configuration = getNativeConfiguration()
        return checkForUpdate(withDeploymentKey: configuration.deploymentKey!)
    }
    
    func checkForUpdate(withDeploymentKey deploymentKey: String) -> CodePushRemotePackage {
        let configuration = getNativeConfiguration()
        configuration.deploymentKey = !deploymentKey.isEmpty ? deploymentKey : configuration.deploymentKey
        // get local pacackage and compare
       // let localPackage =
        
        
        return CodePushRemotePackage()
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * @param packageHash hash to check.
     * @return <code>true</code> if there is a failed update with provided hash, <code>false</code> otherwise.
     */
    func existsFailedUpdate(fromHash packageHash: String) -> Bool {
        return managers.settingsManager.existsFailedUpdate(packageHash)
    }
    
    /**
     * Indicates whether update with specified packageHash is running for the first time.
     *
     * @param packageHash package hash for check.
     * @return true, if application is running for the first time, false otherwise.
     * @throws CodePushNativeApiCallException if error occurred during the operation.
     */
    func isFirstRun(fromHash packageHash: String) -> Bool {
        return (state?.didUpdate)! && !packageHash.isEmpty &&
            packageHash == managers.updateManager.getCurrentPackageHash()
    }
    
    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified <code>updateState</code> parameter.
     *
     * @param updateState current update state.
     * @return installed update metadata.
     */
    func getUpdateMetadata(inState updateState: CodePushUpdateState) throws -> CodePushLocalPackage? {

        var currentPackage = self.managers.updateManager.getCurrentPackage();

        var currentUpdateIsPending = false
        var isDebugOnly = false
        
        if ((currentPackage?.packageHash) != nil) {
            let currentHash = currentPackage?.packageHash
           // currentUpdateIsPending = self.managers.settingsManager.isPendingUpdate(currentHash)

        }
        if (updateState == CodePushUpdateState.PENDING && !self.currentUpdateIsPending) {
            
            /* The caller wanted a pending update but there isn't currently one. */
            return nil;
        } else if (updateState == CodePushUpdateState.RUNNING && currentUpdateIsPending) {
            
            /* The caller wants the running update, but the current one is pending, so we need to grab the previous. */
            let previousPackage = self.managers.updateManager.getPreviousPackage()
            if (previousPackage == nil) {
                return nil;
            } else{
                return previousPackage;
            }
        } else {
            
            /*
             * The current package satisfies the request:
             * 1) Caller wanted a pending, and there is a pending update
             * 2) Caller wanted the running update, and there isn't a pending
             * 3) Caller wants the latest update, regardless if it's pending or not
             */
            if (state.mIsRunningBinaryVersion) {
                
                /*
                 * This only matters in Debug builds. Since we do not clear "outdated" updates,
                 * we need to indicate to the JS side that somehow we have a current update on
                 * disk that is not actually running.
                 */
                isDebugOnly = true;
            }
            
            /* Enable differentiating pending vs. non-pending updates */
            let packageHash = currentPackage?.packageHash
            currentPackage?.failedInstall = existsFailedUpdate(packageHash)
            currentPackage?.isFirstRun = isFirstRun(packageHash)
            currentPackage?.isPending = currentUpdateIsPending
            return currentPackage;
        }
    }
    
    func getNativeConfiguration() -> CodePushConfiguration {
        
        let config = CodePushConfiguration()
        config.appName = self.appName != nil ? self.appName : CodePushConstants.CODE_PUSH_DEFAULT_APP_NAME
        config.appVersion = self.appVersion
        //config.clientUniqueId =
        config.deploymentKey = self.deploymentKey
        config.baseDirectory = self.baseDirectory
        config.serverUrl = self.serverUrl
        config.packageHash = utilities.updateUtils.getHashForBinaryContents()
        return config
    }
}
