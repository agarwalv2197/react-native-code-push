//
//  CodePushUpdateManager.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushUpdateManager {
    
    /**
     * Platform-specific utils implementation.
     */
    var platformUtils: CodePushPlatformUtils
    
    /**
     * Instance of {@link FileUtils} to work with.
     */
    var fileUtils: FileUtils
    
    /**
     * Instance of {@link CodePushUpdateUtils} to work with.
     */
    var codePushUpdateUtils: CodePushUpdateUtils
    
    /**
     * Instance of {@link CodePushUtils} to work with.
     */
    var codePushUtils: CodePushUtils
    
    /**
     * General path for storing files.
     */
    var documentsDirectory: URL
    
    /**
     * CodePush configuration for instance.
     */
    var codePushConfiguration: CodePushConfiguration?
    
    /**
     * Creates instance of CodePushUpdateManager.
     *
     * @param documentsDirectory  path for storing files.
     * @param platformUtils       instance of {@link CodePushPlatformUtils} to work with.
     * @param fileUtils           instance of {@link FileUtils} to work with.
     * @param codePushUtils       instance of {@link CodePushUtils} to work with.
     * @param codePushUpdateUtils instance of {@link CodePushUpdateUtils} to work with.
     * @param codePushConfiguration instance of {@link CodePushConfiguration} to work with.
     */
    init(_ documentsDirectory: URL, _ platformUtils: CodePushPlatformUtils, _ fileUtils: FileUtils,
         _ codePushUtils: CodePushUtils, _ codePushUpdateUtils: CodePushUpdateUtils,
         _ codePushConfiguration: CodePushConfiguration?) {
        self.platformUtils = platformUtils
        self.fileUtils = fileUtils
        self.codePushUpdateUtils = codePushUpdateUtils
        self.codePushUtils = codePushUtils
        self.documentsDirectory = documentsDirectory
        self.codePushConfiguration = codePushConfiguration
    }
    
    /**
     * Gets path to json file containing information about the available packages.
     *
     * @return path to json file containing information about the available packages.
     */
    func getStatusFilePath() -> URL {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: CodePushConstants.StatusFileName)
    }
    
    /**
     * Gets folder for the package by the package hash.
     *
     * @param packageHash current package identifier (hash).
     * @return path to package folder.
     */
    func getPackageFolderPath(withHash packageHash: String) -> URL {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: packageHash)
    }
    
    /**
     * Gets application-specific folder.
     *
     * @return application-specific folder.
     */
    private func getCodePushPath() -> URL {
        return fileUtils.appendPathComponent(atBasePath: self.documentsDirectory, withComponent: (codePushConfiguration?.appName)!)
    }
    
    /**
     * Gets current package json object.
     *
     * @return current package json object.
     * @throws CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getCurrentPackage() -> CodePushLocalPackage? {
        do {
            let packageHash = try getCurrentPackageHash()
            if (packageHash == nil) {
                return nil
            } else {
                return try getPackage(withHash: packageHash!)
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    /**
     * Gets the identifier of the previous installed package (hash).
     *
     * @return the identifier of the previous installed package.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     **/
    func getPreviousPackageHash() throws -> String? {
        let info = try getCurrentPackageInfo()
        return info.previousPackage
    }
    
    /**
     * Gets previous installed package json object.
     *
     * @return previous installed package json object.
     * @throws CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getPreviousPackage() -> CodePushLocalPackage? {
        do {
            let packageHash = try getPreviousPackageHash()
            return try getPackage(withHash: packageHash!)
        } catch {
            print(error)
            return nil
        }
    }
    
    /**
     * Gets package object by its hash.
     *
     * @param packageHash package identifier (hash).
     * @return package object.
     * @throws CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getPackage(withHash packageHash: String) throws -> CodePushLocalPackage {
        let folderPath = getPackageFolderPath(withHash: packageHash)
        let packageFilePath = fileUtils.appendPathComponent(atBasePath: folderPath, withComponent:
            CodePushConstants.PackageFileName)
        
        var localPackage: CodePushLocalPackage
        localPackage = try codePushUtils.getObjectFromJsonFile(packageFilePath)
        return localPackage
    }
    
    /**
     * Gets the identifier of the current package (hash).
     *
     * @return the identifier of the current package.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageHash() throws -> String? {
        let info = try getCurrentPackageInfo()
        return info.currentPackage
    }
    
    /**
     * Gets metadata about the current update.
     *
     * @return metadata about the current update.
     * @throws IOException read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageInfo() throws -> CodePushPackageInfo {
        let statusFilePath = getStatusFilePath()
        if (!fileUtils.fileExists(atPath: statusFilePath)) {
            return CodePushPackageInfo()
        }
        
        var currentPackage: CodePushPackageInfo
        currentPackage = try codePushUtils.getObjectFromJsonFile(statusFilePath)
        return currentPackage
    }
    
    /**
     * Gets folder for storing current package files.
     *
     * @return folder for storing current package files.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageFolderPath() throws -> URL? {
        let packageHash = try getCurrentPackageHash()
        if (packageHash == nil) {
            return nil
        } else {
            return getPackageFolderPath(withHash: packageHash!)
        }
    }
    
    /**
     * Deletes the current package and installs the previous one.
     *
     * @throws CodePushRollbackException exception occurred during package rollback.
     */
    func rollbackPackage() throws {
        do {
            let info = try getCurrentPackageInfo()
            let currentPackageFolderPath = try getCurrentPackageFolderPath()
            
            try fileUtils.deleteDirectoryAtPath(path: currentPackageFolderPath!)
            
            info.currentPackage = info.previousPackage
            info.previousPackage = nil
            try updateCurrentPackageInfo(package: info)
        } catch {
            print(error)
            throw CodePushPackageErrors.FailedRollback
        }
    }
    
    /**
     * Updates file containing information about the available packages.
     *
     * @param packageInfo new information.
     * @throws IOException read/write error occurred while accessing the file system.
     */
    func updateCurrentPackageInfo(package packageInfo: CodePushPackageInfo) throws {
        try codePushUtils.writeObjectToJsonFile(withObject: packageInfo, atPath: getStatusFilePath())
    }
    
    /**
     * Downloads the update package.
     *
     * @param packageHash            update package hash.
     * @param downloadPackageRequest instance of {@link ApiHttpRequest} to download the update.
     * @return downloaded package.
     * @throws CodePushDownloadPackageException an exception occurred during package downloading.
     */
    func downloadPackage(withHash packageHash: String, atUrl url: String,
                         callback completion: @escaping (Result<CodePushDownloadPackageResult>) -> Void) {
        let newUpdateFolderPath = getPackageFolderPath(withHash: packageHash)
        
        if (fileUtils.fileExists(atPath: newUpdateFolderPath)) {
            
            /* This removes any stale data in <code>newPackageFolderPath</code> that could have been left
             * uncleared due to a crash or error during the download or install process. */
            do {
                try fileUtils.deleteDirectoryAtPath(path: newUpdateFolderPath)
            } catch {
                completion(Result { throw CodePushPackageErrors.FailedDownload })
                return
            }
        }
        let resolvedUrl = URL(string: url)
        let api = ApiRequest(resolvedUrl!)
        api.downloadUpdate(completion: { result in
            completion( Result {
                let temporaryPath = try result.resolve()
                return CodePushDownloadPackageResult(temporaryPath, false)
            })
        })
    }
    
    /**
     * Installs the new package.
     *
     * @param packageHash         package hash to install.
     * @param removePendingUpdate whether to remove pending updates data.
     * @throws CodePushInstallException exception occurred during package installation.
     */
    func installPackage(packageHashToInstall packageHash: String?, removeCurrentUpdate removeCurrent: Bool) throws {
        do {
            let info = try getCurrentPackageInfo()
            let currentPackageHash = try getCurrentPackageHash()
            if (packageHash != nil && packageHash == currentPackageHash) {
                /* The current package is already the one being installed, so we should no-op. */
                return
            }
            if (removeCurrent) {
                let currentPackageFolderPath = try getCurrentPackageFolderPath()
                if (currentPackageFolderPath != nil) {
                    try fileUtils.deleteDirectoryAtPath(path: currentPackageFolderPath!)
                }
            } else {
                let previousPackageHash = try getPreviousPackageHash()
                if (previousPackageHash != nil && previousPackageHash != packageHash) {
                    try fileUtils.deleteDirectoryAtPath(path: getPackageFolderPath(withHash: previousPackageHash!))
                }
                info.previousPackage = info.currentPackage
            }
            info.currentPackage = packageHash
            try updateCurrentPackageInfo(package: info)
        } catch {
            print(error)
            throw CodePushPackageErrors.FailedInstall
        }
    }
}
