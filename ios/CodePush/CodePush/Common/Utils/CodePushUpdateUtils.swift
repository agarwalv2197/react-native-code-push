//
//  CodePushUpdateUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Utils class for CodePush updates.
 */
class CodePushUpdateUtils {
    
    static let sharedInstance = CodePushUpdateUtils()
    let fileUtils: FileUtils
    let codePushUtils: CodePushUtils

    private init() {
        self.fileUtils = FileUtils.sharedInstance
        self.codePushUtils = CodePushUtils.sharedInstance
    }

    /**
     * Fills new package directory with files following diff manifest rules:
     * copy current installed package files to destination directory
     * delete files from destination directory specified in `deletedFiles` of diff manifest.
     *
     * Parameter diffManifestFilePath     path to diff manifest file.
     * Parameter currentPackageFolderPath path to current package directory.
     * Parameter newPackageFolderPath     path to new package directory.
     * Throws: Error due to IO exceptions
     */
    func copyNecessaryFilesFromCurrentPackage(diffFile diffManifestFilePath: URL,
                                              currentPackagePath currentPackageFolderPath: URL,
                                              newPackagePath newPackageFolderPath: URL) throws {

        // Copy the current package contents to the directory of the new update
        try fileUtils.copyDirectoryContents(fromSource: currentPackageFolderPath, toDest: newPackageFolderPath)
        let diffManifest: CodePushDiffManifest = try codePushUtils.getObjectFromJsonFile(diffManifestFilePath)

        // Delete all files specified by the manifest
        for file in diffManifest.deletedFiles {

            // Need to remove the first component of the path
            let subUrl = file.pathComponents[2...].reduce(URL(string: file.pathComponents[1])!, {
                return fileUtils.appendPathComponent(atBasePath: $0, withComponent: $1)
            })

            let fileToDelete = fileUtils.appendPathComponent(atBasePath: newPackageFolderPath,
                                                             withComponent: subUrl.path)
            if fileUtils.fileExists(atPath: fileToDelete) {
                try fileUtils.deleteEntityAtPath(path: fileToDelete)
            }
        }
    }

    /**
     * Recursively searches for the specified entry point in update files.
     *
     * Parameter folderPath       path to folder containing update files (search location).
     * Parameter expectedFileName expected file name of the entry point.
     * Returns: full path to entry point.
     * Throws: Error due to IO exceptions
     */
    func findEntryPointInUpdateContents(atOrigin folderPath: URL,
                                        targetFile expectedFileName: String) throws -> URL? {
        let files = try FileManager.default.contentsOfDirectory(atPath: folderPath.path)
        for file in files {
            let fullFilePath = fileUtils.appendPathComponent(atBasePath: folderPath, withComponent: file)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: fullFilePath.path, isDirectory: &isDir)
            if isDir.boolValue {
                let mainBundlePathInSubFolder = try findEntryPointInUpdateContents(atOrigin: fullFilePath,
                                                                                   targetFile: expectedFileName)
                if mainBundlePathInSubFolder != nil {
                    return mainBundlePathInSubFolder
                }
            } else {
                if file == expectedFileName {
                    return fullFilePath
                }
            }
        }
        return nil
    }
}
