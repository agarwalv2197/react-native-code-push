//
//  CodePushBaseCore.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushBaseCore {
    
    var deploymentKey: String
    var baseDirectory: URL
    var serverUrl: String
    var appName: String
    var appVersion: String
    var state: CodePushState
    var utilities: CodePushUtilities
    var managers: CodePushManagers
    var appEntryPoint: String
    
    /**
     * Creates instance of {@link CodePushBaseCore}. Default constructor.
     * We pass {@link Application} and app secret here, too, because we can't initialize AppCenter in another constructor and then call this.
     * However, AppCenter must be initialized before creating anything else.
     *
     * Parameter deploymentKey         deployment key.
     * Parameter appSecret             the value of app secret from AppCenter portal to configure {@link Crashes} sdk.
     *                                 Pass ```nil``` if you don't need {@link Crashes} integration for tracking exceptions.
     * Parameter isDebugMode           indicates whether application is running in debug mode.
     * Parameter baseDirectory         Base directory for CodePush files.
     * Parameter serverUrl             CodePush server url.
     * Parameter appName               application name.
     * Parameter appVersion            application version.
     * Parameter appEntryPointProvider instance of {@link CodePushAppEntryPointProvider}.
     * Parameter platformUtils         instance of {@link CodePushPlatformUtils}.
     * Throws: CodePushInitializeException error occurred during the initialization.
     */
    init(_ deploymentKey: String,
         _ appSecret: String,
         _ isDebugMode: Bool,
         _ baseDirectory: URL?,
         _ serverUrl: String,
         _ appName: String,
         _ appVersion: String,
         _ appEntryPointProvider: CodePushAppEntryPointProvider,
         _ platformUtils: CodePushPlatformUtils) throws {
        
        /* Initialize configuration. */
        self.deploymentKey = deploymentKey
        self.serverUrl = serverUrl
        self.appName = appName
        self.appVersion = appVersion
        
        /* Initialize state */
        self.state = CodePushState()
        
        do {
            self.appEntryPoint = try appEntryPointProvider.getAppEntryPoint()
        } catch {
            print(error)
            throw CodePushErrors.InitializationError
        }
        
        /* Initialize utilities. */
        let fileUtils = FileUtils.sharedInstance
        let utils = CodePushUtils.sharedInstance
        let updateUtils = CodePushUpdateUtils.sharedInstance
        self.utilities = CodePushUtilities(utils, fileUtils, updateUtils, platformUtils)
        
        self.baseDirectory = baseDirectory != nil ? baseDirectory! :
            self.utilities.fileUtils.appendPathComponent(atBasePath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
                                                         withComponent: CodePushConstants.CodePushFolderPrefix)
        
        /* Initialize managers. */
        let updateManager = CodePushUpdateManager(self.baseDirectory, platformUtils, fileUtils, utils, updateUtils, nil)
        let settingsManager = CodePushSettingsManager(utils, nil)
        
        let acquisitionManager = CodePushAcquisitionManager(utilities.utils, utilities.fileUtils)
        self.managers = CodePushManagers(updateManager, acquisitionManager, settingsManager)
        
        let configuration = try getNativeConfiguration()
        managers.updateManager.codePushConfiguration = configuration
        managers.settingsManager.codePushConfiguration = configuration
        
        try initializeUpdateAfterRestart()
    }
    
    /**
     * Initializes update after app restart.
     *
     * Throws: CodePushGetPackageException    if error occurred during the getting current package.
     * Throws: CodePushPlatformUtilsException if error occurred during usage of {@link CodePushPlatformUtils}.
     * Throws: CodePushRollbackException      if error occurred during rolling back of package.
     */
    func initializeUpdateAfterRestart() throws {
        
        /* Reset the state which indicates that the app was just freshly updated. */
        state.didUpdate = false
        let pendingUpdate = try managers.settingsManager.getPendingUpdate()
        if (pendingUpdate != nil) {
            let packageMetadata = managers.updateManager.getCurrentPackage()
            if (packageMetadata == nil || !utilities.platformUtils.isPackageLatest(packageMetadata!, appVersion) &&
                appVersion == packageMetadata?.appVersion) {
                return
            }
            let updateIsLoading = pendingUpdate?.pendingUpdateIsLoading
            if (updateIsLoading!) {
                
                /* Pending update was initialized, but notifyApplicationReady was not called.
                 * Therefore, deduce that it is a broken update and rollback. */
                state.needToReportRollback = true
                try rollbackPackage()
            } else {
                
                /* There is in fact a new update running for the first
                 * time, so update the local state to ensure the client knows. */
                state.didUpdate = true
                
                /* Mark that we tried to initialize the new update, so that if it crashes,
                 * we will know that we need to rollback when the app next starts. */
                managers.settingsManager.removePendingUpdate()
            }
        }
    }
    
    func checkForUpdate(callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        var configuration: CodePushConfiguration
        do {
            configuration = try getNativeConfiguration()
        } catch {
            completion(Result{throw error})
            return
        }
        checkForUpdate(withKey: configuration.deploymentKey!, callback: completion)
    }
    
    /**
     * Checks whether an update with the following hash has failed.
     *
     * Parameter packageHash hash to check.
     * Returns: ```true``` if there is a failed update with provided hash, ```false``` otherwise.
     */
    func existsFailedUpdate(fromHash packageHash: String) throws -> Bool {
        return try managers.settingsManager.existsFailedUpdate(withHash: packageHash)
    }
    
    /**
     * Gets native CodePush configuration.
     *
     * Returns: native CodePush configuration.
     */
    func getNativeConfiguration() throws -> CodePushConfiguration {
        let config = CodePushConfiguration()
        config.appName = !self.appName.isEmpty ? self.appName : CodePushConstants.CodePushDefaultAppName
        config.appVersion = !self.appVersion.isEmpty ? self.appVersion : try getAppVersion()
        config.clientUniqueId = UIDevice.current.identifierForVendor!.uuidString
        config.deploymentKey = self.deploymentKey
        config.baseDirectory = self.baseDirectory
        config.serverUrl = !self.serverUrl.isEmpty ? self.serverUrl : CodePushConstants.CodePushServer
        return config
    }
    
    private func getAppVersion() throws -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            else { throw CodePushErrors.InitializationError }
        return version
    }
    
    /**
     * Asks the CodePush service whether the configured app deployment has an update available
     * using specified deployment key.
     *
     * Parameter deploymentKey deployment key to use.
     * Returns: remote package info if there is an update, ```nil``` otherwise.
     * Throws: CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func checkForUpdate(withKey deploymentKey: String,
                        callback completion: @escaping (Result<CodePushRemotePackage?>) -> Void) {
        
        var configuration: CodePushConfiguration
        do {
            configuration = try getNativeConfiguration()
        } catch {
            completion(Result{throw error})
            return
        }
        
        configuration.deploymentKey = !deploymentKey.isEmpty ? deploymentKey : configuration.deploymentKey
        do {
            let localPackage = try getUpdateMetadata(inUpdateState: .LATEST)
            let queryPackage = localPackage != nil ? localPackage :
                CodePushLocalPackage.createEmptyPackageForUpdateQuery(withVersion: configuration.appVersion)
            CodePushAcquisitionManager(utilities.utils, utilities.fileUtils)
                .queryUpdate(withConfig: configuration, withPackage: queryPackage!,
                             callback: { result in
                                completion( Result {
                                    let update = try result.resolve()
                                    if (update == nil || update?.packageHash == localPackage?.packageHash) {
                                        return nil
                                    } else {
                                        return update
                                    }
                                })
                })
        } catch {
            completion (Result { throw error })
        }
    }
    
    /**
     * Synchronizes your app assets with the latest release to the configured deployment.
     *
     * Throws: CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func sync(callback completion: @escaping (Result<Bool>) -> Void) {
        self.sync(withOptions: CodePushSyncOptions(), callback: completion)
    }
    
    /**
     * Synchronizes your app assets with the latest release to the configured deployment.
     *
     * Parameter synchronizationOptions sync options.
     * Throws: CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func sync(withOptions syncOptions: CodePushSyncOptions,
              callback completion: @escaping (Result<Bool>) -> Void) {
        if (syncOptions.deploymentKey.isEmpty) {
            syncOptions.deploymentKey = deploymentKey
        }
        if (syncOptions.installMode == nil) {
            syncOptions.installMode = .ON_NEXT_RESTART
        }
        if (syncOptions.mandatoryInstallMode == nil) {
            syncOptions.mandatoryInstallMode = .IMMEDIATE
        }
        if (syncOptions.checkFrequency == nil) {
            syncOptions.checkFrequency = .ON_APP_START
        }
        
        var configuration: CodePushConfiguration
        do {
            configuration = try getNativeConfiguration()
        } catch {
            completion(Result{throw error})
            return
        }
        
        if (!syncOptions.deploymentKey.isEmpty) {
            configuration.deploymentKey = syncOptions.deploymentKey
        }
        
        checkForUpdate(withKey: syncOptions.deploymentKey, callback: { result in
            do {
                let remotePackage = try result.resolve()
                if (remotePackage == nil) {
                    completion(Result { return false })
                } else {
                    self.doDownloadAndInstall(package: remotePackage!, withOptions: syncOptions, withConfig: configuration, callback: { result in
                        completion(Result{ return try result.resolve() })
                    })
                }
            } catch {
                completion(Result { throw error })
            }
        })
        
        //                let basePackage = CodePushPackage()
        //                basePackage.deploymentKey = "i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf"
        //                basePackage.packageHash = "12f376f76b1bfd68103aaa1db84ba5ea7284951e0af02aff33bf7aa880d9ec51"
        //                basePackage.label = "v14"
        //                basePackage.isMandatory = false
        //                basePackage.failedInstall = false
        //                basePackage.description = "version 1.0.8 working"
        //                basePackage.appVersion = "1.0.0"
        //                let remotePackage = CodePushRemotePackage.createRemotePackage(fromFailedInstall: false, size: 186598, atUrl: "https://codepush.blob.core.windows.net/storagev2/0GqmGWPkR6xVG8SvaF8QN3wLmbWE12058267-11c6-40ff-b975-6397a0cb8e3e", updateVersion: false, fromPackage: basePackage)
        
        //        let basePackage = CodePushPackage()
        //        basePackage.deploymentKey = "i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf"
        //        basePackage.packageHash = "fc1a577f0f197592cd1fd56f59870b0fb7a6d825154e2a2f2b07730bbaa1fc5e"
        //        basePackage.label = "v15"
        //        basePackage.isMandatory = false
        //        basePackage.failedInstall = false
        //        basePackage.description = "version 1.0.8 working"
        //        basePackage.appVersion = "1.0.0"
        //        let remotePackage = CodePushRemotePackage.createRemotePackage(fromFailedInstall: false, size: 186668, atUrl: "https://codepush.blob.core.windows.net/storagev2/Y7LDcrLVt9vRMNNx9CT56S2SC-cM12058267-11c6-40ff-b975-6397a0cb8e3e", updateVersion: false, fromPackage: basePackage)
        //
        //                self.doDownloadAndInstall(package: remotePackage, withOptions: syncOptions, withConfig: configuration, callback: { result in
        //                    completion(Result {return try result.resolve()})
        //                })
        
    }
    
    /**
     * Downloads and installs update.
     *
     * Parameter remotePackage update to use.
     * Parameter syncOptions   sync options.
     * Parameter configuration configuration to use.
     * Parameter callback delegate to return to
     * Throws: CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func doDownloadAndInstall(package remotePackage: CodePushRemotePackage,
                              withOptions syncOptions: CodePushSyncOptions,
                              withConfig configuration: CodePushConfiguration,
                              callback completion: @escaping (Result<Bool>) -> Void) {
        downloadUpdate(package: remotePackage, callback: { result in
            completion ( Result {
                let localPackage = try result.resolve()
                return try self.installUpdate(withPackage: localPackage)
            })
        })
    }
    
    /**
     * Downloads update.
     *
     * Parameter updatePackage update to download.
     * Parameter callback delegate to return to
     * Returns: resulted local package or error
     */
    func downloadUpdate(package updatePackage: CodePushRemotePackage,
                        callback completion: @escaping (Result<CodePushLocalPackage>) -> Void) {
        
        let downloadUrl = updatePackage.downloadURL
        
        managers.updateManager
            .downloadPackage(withHash: updatePackage.packageHash!,
                             atUrl: downloadUrl!,
                             callback: { result in
                                completion ( Result {
                                    do {
                                        let downloadResult = try result.resolve()
                                        
                                        // Create the directory if it doesn't exist
                                        let newUpdateFolderPath = self.managers.updateManager.getPackageFolderPath(withHash: updatePackage.packageHash!)
                                        try self.utilities.fileUtils.createDirectoryIfNotExists(path: newUpdateFolderPath)
                                        
                                        let newUpdateMetadataPath = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath,
                                                                                                                 withComponent: CodePushConstants.PackageFileName)
                                        if (downloadResult.isZip) {
                                            
                                            let zipLocation = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath,
                                                                                                 withComponent: CodePushConstants.ZipFileName)
                                            try self.utilities.fileUtils.moveFile(file: downloadResult.downloadFile, toDestination: zipLocation)
                                            
                                            let newUpdateDirectoryPath = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath,
                                                                                                                 withComponent: self.appName)
                                            try self.utilities.fileUtils.unzipDirectory(source: zipLocation,
                                                                                        destination: newUpdateDirectoryPath)
                                        } else {
                                            let newUpdateFilePath = self.utilities.fileUtils.appendPathComponent(atBasePath: newUpdateFolderPath,
                                                                                                                 withComponent: self.appEntryPoint)
                                            try self.utilities.fileUtils.moveFile(file: downloadResult.downloadFile, toDestination: newUpdateFilePath)
                                        }
                                        let newPackage = CodePushLocalPackage.createLocalPackage(wasFailedInstall: false, isFirstRun: false, isPending: true,
                                                                                                 isDebugOnly: false, withEntryPoint: self.appEntryPoint,
                                                                                                 fromPackage: updatePackage)
                                        try self.utilities.utils.writeObjectToJsonFile(withObject: newPackage, atPath: newUpdateMetadataPath)
                                        
                                        return newPackage
                                    } catch {
                                        try self.managers.settingsManager.saveFailedUpdate(forPackage: updatePackage)
                                        throw error
                                    }
                                })
            } )
        
    }
    
    /**
     * Unzips the following package file.
     *
     * Parameter downloadFile package file.
     * Throws: CodePushUnzipException an exception occurred during unzipping.
     */
    func unzipPackage(downloadFile: URL) throws {
        
        
//        let unzippedFolderPath = getUnzippedFolderPath()
//        do {
//        let unzippedFolder = new File(unzippedFolderPath);
//        utilites.fileUtils.unzipFile(downloadFile, unzippedFolder);
//        utilities.fileUtils.deleteFileOrFolderSilently(downloadFile);
//
//        // Rename app package directory to match configured app name
//        for (var file : unzippedFolder.listFiles()) {
//        if (file.isDirectory()) {
//            if (!file.renameTo(new File(unzippedFolder, mCodePushConfiguration.getAppName()))) {
//                throw new IOException("Unable to rename package file.");
//        }
//        return
//        }
//        }
//        } catch (IOException e) {
//        throw new CodePushUnzipException(e);
//        }
    }
    
    /**
     * Installs update.
     *
     * Parameter updatePackage             update to install.
     * Throws: CodePushNativeApiCallException if error occurred during the execution of operation.
     */
    func installUpdate(withPackage updatePackage: CodePushLocalPackage) throws -> Bool {
        try managers.updateManager.installPackage(packageHashToInstall: updatePackage.packageHash, removeCurrentUpdate: managers.settingsManager.isPendingUpdate(withHash: nil))
        
        let pendingHash = updatePackage.packageHash
        if (pendingHash?.isEmpty)! {
            throw CodePushErrors.NoHashValue
        } else {
            let pendingUpdate = CodePushPendingUpdate()
            pendingUpdate.pendingUpdateHash =  pendingHash
            pendingUpdate.pendingUpdateIsLoading = false
            try managers.settingsManager.savePendingUpdate(forUpdate: pendingUpdate)
        }
        return true
    }
    
    /**
     * Retrieves the metadata for an installed update (e.g. description, mandatory)
     * whose state matches the specified ```updateState``` parameter.
     *
     * Parameter updateState current update state.
     * Returns: installed update metadata.
     * Throws: CodePushNativeApiCallException if error occurred during the operation.
     */
    public func getUpdateMetadata(inUpdateState updateState: CodePushUpdateState) throws -> CodePushLocalPackage? {
        guard let currentPackage = managers.updateManager.getCurrentPackage() else { return nil }
        
        var currentUpdateIsPending = false
        if (!(currentPackage.packageHash?.isEmpty)!) {
            let currentHash = currentPackage.packageHash
            currentUpdateIsPending = try managers.settingsManager.isPendingUpdate(withHash: currentHash!)
        }
        if (updateState == .PENDING && !currentUpdateIsPending) {
            
            /* The caller wanted a pending update but there isn't currently one. */
            return nil
        } else if (updateState == .RUNNING && currentUpdateIsPending) {
            
            /* The caller wants the running update, but the current one is pending, so we need to grab the previous. */
            let previousPackage = managers.updateManager.getPreviousPackage()
            return previousPackage
        } else {
            /* Enable differentiating pending vs. non-pending updates */
            let packageHash = currentPackage.packageHash
            currentPackage.failedInstall = try managers.settingsManager.existsFailedUpdate(withHash: packageHash!)
            currentPackage.isFirstRun = try isFirstRun(withHash: packageHash!)
            currentPackage.isPending = currentUpdateIsPending
            return currentPackage
        }
    }
    
    /**
     * Indicates whether update with specified packageHash is running for the first time.
     *
     * Parameter packageHash package hash for check.
     * Returns: ```true```, if application is running for the first time, ```false``` otherwise.
     * Throws: CodePushNativeApiCallException if error occurred during the operation.
     */
    func isFirstRun(withHash packageHash: String) throws -> Bool {
        let currentPackageHash = try managers.updateManager.getCurrentPackageHash()
        return state.didUpdate!
            && !packageHash.isEmpty
            && packageHash == currentPackageHash
    }
    
    /**
     * Rolls back package.
     *
     * Throws: CodePushGetPackageException if error occurred during getting current update.
     * Throws: CodePushRollbackException   if error occurred during rolling back of package.
     * Throws: CodePushMalformedDataException
     */
    func rollbackPackage() throws {
        let failedPackage = managers.updateManager.getCurrentPackage()
        if (failedPackage != nil) {
            try managers.settingsManager.saveFailedUpdate(forPackage: failedPackage!)
            try managers.updateManager.rollbackPackage()
            managers.settingsManager.removePendingUpdate()
        }
    }
    
    /**
     * Gets the path of the installed package
     * Returns: The directory of the installed package
     */
    public func getCurrentPackagePath() throws -> URL? {
        return try managers.updateManager.getCurrentPackagePath()
    }
    
    /**
     * Gets the path of the previously installed package
     * Returns: The directory of the previously installed package
     */
    public func getPreviousPackagePath() throws -> URL? {
        return try managers.updateManager.getPreviousPackagePath()
    }
}
