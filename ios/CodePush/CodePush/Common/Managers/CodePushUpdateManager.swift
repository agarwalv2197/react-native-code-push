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
    var documentsDirectory: String
    
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
    init(_ documentsDirectory: String, _ platformUtils: CodePushPlatformUtils, _ fileUtils: FileUtils,
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
    func getStatusFilePath() -> String {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: CodePushConstants.STATUS_FILE_NAME)
    }
    
    /**
     * Gets folder for the package by the package hash.
     *
     * @param packageHash current package identifier (hash).
     * @return path to package folder.
     */
    func getPackageFolderPath(withHash packageHash: String) -> String {
        return fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: packageHash)
    }
    
    /**
     * Gets application-specific folder.
     *
     * @return application-specific folder.
     */
    private func getCodePushPath() -> String {
        let codePushPath = fileUtils.appendPathComponent(atBasePath: self.documentsDirectory, withComponent: (codePushConfiguration?.appName)!)
        return codePushPath
    }
    
    /**
     * Gets current package json object.
     *
     * @return current package json object.
     * @throws CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getCurrentPackage() -> CodePushLocalPackage? {
        let packageHash = getCurrentPackageHash()
        if (packageHash == nil) {
            return nil
        } else {
            do {
                let hash = try getPackage(withHash: packageHash!)
                return hash
            } catch {fatalError("")}
        }
    }
    
    /**
     * Gets the identifier of the previous installed package (hash).
     *
     * @return the identifier of the previous installed package.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     **/
    func getPreviousPackageHash() -> String? {
        let info = getCurrentPackageInfo()
        return info.previousPackage
    }
    
    /**
     * Gets previous installed package json object.
     *
     * @return previous installed package json object.
     * @throws CodePushGetPackageException exception occurred when obtaining a package.
     */
    func getPreviousPackage() throws -> CodePushLocalPackage? {
        let packageHash = getPreviousPackageHash();

        do {
            let hash = try getPackage(withHash: packageHash!)
            return hash
        } catch {fatalError("")}
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
            CodePushConstants.PACKAGE_FILE_NAME)

        do {
            var object: CodePushLocalPackage
            object = try codePushUtils.getObjectFromJsonFile(packageFilePath)
            return object
        } catch {fatalError("")}
    }
    
    /**
     * Gets the identifier of the current package (hash).
     *
     * @return the identifier of the current package.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageHash() -> String? {
        let info = getCurrentPackageInfo()
        return info.currentPackage
    }
    
    /**
     * Gets file for package download.
     *
     * @return file for package download.
     * @throws IOException if read/write error occurred while accessing the file system.
     */
    func getPackageDownloadFile() throws -> String {

        if (!FileManager.default.fileExists(atPath: getCodePushPath())) {
            do {
                try FileManager.default.createDirectory(atPath: getCodePushPath(), withIntermediateDirectories: false, attributes: nil)
            } catch {
                throw error
            }
        }
        let filePath = fileUtils.appendPathComponent(atBasePath: getCodePushPath(), withComponent: CodePushConstants.DOWNLOAD_FILE_NAME)
        FileManager.default.createFile(atPath: filePath, contents: nil)
        return filePath
    }
    
    /**
     * Gets metadata about the current update.
     *
     * @return metadata about the current update.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageInfo() -> CodePushPackageInfo {
        let statusFilePath = getStatusFilePath();
        if (!fileUtils.fileExists(atPath: statusFilePath)) {
            return CodePushPackageInfo()
        }
        do {
            var object: CodePushPackageInfo
            object = try codePushUtils.getObjectFromJsonFile(statusFilePath)
            return object
        } catch {fatalError("")}
    }
    
    /**
     * Gets folder for storing current package files.
     *
     * @return folder for storing current package files.
     * @throws IOException                    read/write error occurred while accessing the file system.
     * @throws CodePushMalformedDataException error thrown when actual data is broken (i .e. different from the expected).
     */
    func getCurrentPackageFolderPath() -> String? {
        let packageHash = getCurrentPackageHash()
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
    func rollbackPackage() {
        let info = getCurrentPackageInfo()
        let currentPackageFolderPath = getCurrentPackageFolderPath()
        do {
            try fileUtils.deleteDirectoryAtPath(path: currentPackageFolderPath!)
        } catch {}
        
        info.currentPackage = info.previousPackage
        info.previousPackage = nil
        updateCurrentPackageInfo(package: info)
    }
    
    /**
     * Updates file containing information about the available packages.
     *
     * @param packageInfo new information.
     * @throws IOException read/write error occurred while accessing the file system.
     */
    func updateCurrentPackageInfo(package packageInfo: CodePushPackageInfo) {
        do {
            try codePushUtils.writeObjectToJsonFile(withObject: packageInfo, atPath: getStatusFilePath());
        } catch {fatalError("")}
    }
}
