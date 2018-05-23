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
     * Byte signature designating a compressed folder
     */
    let ZipHeader = [0x50, 0x4b, 0x03, 0x04]
    
    /**
     * Creates instance of CodePushUpdateManager.
     *
     * Parameter documentsDirectory  path for storing files.
     * Parameter platformUtils       instance of {@link CodePushPlatformUtils} to work with.
     * Parameter fileUtils           instance of {@link FileUtils} to work with.
     * Parameter codePushUtils       instance of {@link CodePushUtils} to work with.
     * Parameter codePushUpdateUtils instance of {@link CodePushUpdateUtils} to work with.
     * Parameter codePushConfiguration instance of {@link CodePushConfiguration} to work with.
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
     * Returns: path to json file containing information about the available packages.
     */
    func getStatusFilePath() -> URL {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: CodePushConstants.StatusFileName)
    }
    
    /**
     * Gets folder for the package by the package hash.
     *
     * Parameter packageHash current package identifier (hash).
     * Returns: path to package folder.
     */
    func getPackageFolderPath(withHash packageHash: String) -> URL {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: packageHash)
    }
    
    /**
     * Gets application-specific folder.
     *
     * Returns: application-specific folder.
     */
    private func getCodePushPath() -> URL {
        return fileUtils.appendPathComponent(atBasePath: self.documentsDirectory, withComponent: (codePushConfiguration?.appName)!)
    }
    
    /**
     * Gets current package json object.
     *
     * Returns: current package json object.
     * Throws: CodePushGetPackageException exception occurred when obtaining a package.
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
     * Returns: the identifier of the previous installed package.
     * Throws: IOException                    read/write error occurred while accessing the file system.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     **/
    func getPreviousPackageHash() throws -> String? {
        let info = try getCurrentPackageInfo()
        return info.previousPackage
    }
    
    /**
     * Gets previous installed package json object.
     *
     * Returns: previous installed package json object.
     * Throws: CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getPreviousPackage() -> CodePushLocalPackage? {
        do {
            let packageHash = try getPreviousPackageHash()
            if (packageHash != nil) {
                return try getPackage(withHash: packageHash!)
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    /**
     * Gets package object by its hash.
     *
     * Parameter packageHash package identifier (hash).
     * Returns: package object.
     * Throws: CodePushGetPackageException exception occurred when obtaining a package.
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
     * Returns: the identifier of the current package.
     * Throws: IOException                    read/write error occurred while accessing the file system.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageHash() throws -> String? {
        let info = try getCurrentPackageInfo()
        return info.currentPackage
    }
    
    /**
     * Gets metadata about the current update.
     *
     * Returns: metadata about the current update.
     * Throws: IOException read/write error occurred while accessing the file system.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
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
     * Returns: folder for storing current package files.
     * Throws: IOException                    read/write error occurred while accessing the file system.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackagePath() throws -> URL? {
        let packageHash = try getCurrentPackageHash()
        if (packageHash == nil) {
            return nil
        } else {
            return getPackageFolderPath(withHash: packageHash!)
        }
    }
    
    /**
     * Gets folder for storing current package files.
     *
     * Returns: folder for storing previous package files.
     * Throws: IOException                    read/write error occurred while accessing the file system.
     * Throws: CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getPreviousPackagePath() throws -> URL? {
        let packageHash = try getPreviousPackageHash()
        if (packageHash == nil) {
            return nil
        } else {
            return getPackageFolderPath(withHash: packageHash!)
        }
    }
    
    /**
     * Deletes the current package and installs the previous one.
     *
     * Throws: CodePushRollbackException exception occurred during package rollback.
     */
    func rollbackPackage() throws {
        do {
            let info = try getCurrentPackageInfo()
            let currentPackageFolderPath = try getCurrentPackagePath()
            
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
     * Parameter packageInfo new information.
     * Throws: IOException read/write error occurred while accessing the file system.
     */
    func updateCurrentPackageInfo(package packageInfo: CodePushPackageInfo) throws {
        try codePushUtils.writeObjectToJsonFile(withObject: packageInfo, atPath: getStatusFilePath())
    }
    
    /**
     * Downloads the update package.
     *
     * Parameter packageHash            update package hash.
     * Parameter downloadPackageRequest instance of {@link ApiHttpRequest} to download the update.
     * Returns: downloaded package.
     * Throws: CodePushDownloadPackageException an exception occurred during package downloading.
     */
    func downloadPackage(withHash packageHash: String, atUrl url: URL,
                         callback completion: @escaping (Result<CodePushDownloadPackageResult>) -> Void) {
        let newUpdateFolderPath = getPackageFolderPath(withHash: packageHash)
        
        if (fileUtils.fileExists(atPath: newUpdateFolderPath)) {
            
            /* This removes any stale data in ```newPackageFolderPath``` that could have been left
             * uncleared due to a crash or error during the download or install process. */
            do {
                try fileUtils.deleteDirectoryAtPath(path: newUpdateFolderPath)
            } catch {
                completion(Result { throw CodePushPackageErrors.FailedDownload })
                return
            }
        }

        let api = ApiRequest(url)
        api.downloadUpdate(completion: { result in
            completion( Result {
                var temporaryPath = try result.resolve()
                let fileSignature = try Data(contentsOf: temporaryPath)[...(self.ZipHeader.count - 1)]
                var isZip = true
                for (i, element) in self.ZipHeader.enumerated() {
                    if (element != fileSignature[i]) {
                        isZip = false
                        break
                    }
                }
                
                return CodePushDownloadPackageResult(temporaryPath, isZip)
            })
        })
    }
    
    /**
     * Installs the new package.
     *
     * Parameter packageHash         package hash to install.
     * Parameter removePendingUpdate whether to remove pending updates data.
     * Throws: CodePushInstallException exception occurred during package installation.
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
                let currentPackageFolderPath = try getCurrentPackagePath()
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
