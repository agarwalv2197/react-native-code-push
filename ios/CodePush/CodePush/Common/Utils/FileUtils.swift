//
//  FileUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation
import SSZipArchive

class FileUtils {

    static let sharedInstance = FileUtils()
    private init() {}

    /**
     * Checks whether a file by the following path exists.
     *
     * Parameter filePath path to be checked.
     * Returns: ```true``` if exists, ```false``` otherwise.
     */
    func fileExists(atPath filePath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.relativePath)
    }

    /**
     * Appends file path with one more component.
     *
     * Parameter basePath            path to be appended.
     * Parameter appendPathComponent path component to be appended to the base path.
     * Returns: new path.
     */
    func appendPathComponent(atBasePath basePath: URL, withComponent appendPathComponent: String) -> URL {
        return basePath.appendingPathComponent(appendPathComponent)
    }

    /**
     * Writes some content to a file, existing file will be overwritten.
     *
     * Parameter content  content to be written to a file.
     * Parameter filePath path to a file.
     * Throws: IO Error
     */
    func writeToFile(withContent content: String, atPath filePath: URL) throws {
        try content.write(to: filePath, atomically: false, encoding: .utf8)
    }

    /**
     * Reads the contents of file to a string.
     *
     * Parameter filePath path to file to be read.
     * Returns: string with contents of the file.
     * Throws: IO Error
     */
    func readFileToString(atPath filePath: URL) throws -> String {
        return try String(contentsOf: filePath, encoding: .utf8)
    }

    /**
     * Move a file to a destination
     *
     * Parameter origin the original location of the file
     * Parameter destination path of the file
     * Throws: if the file already exists at the destination or due to IO errors.
     */
    func moveFile(file origin: URL, toDestination destination: URL) throws {
        try FileManager.default.moveItem(at: origin, to: destination)
    }

    /**
     * Copy a file to a destination
     *
     * Parameter origin the original location of the file
     * Parameter destination path of the file
     * Throws: if the file already exists at the destination or due to IO errors.
     */
    func copyFile(file origin: URL, toDestination destination: URL) throws {
        try FileManager.default.copyItem(at: origin, to: destination)
    }

    /**
     * Creates a new directory if it doesn't already exist
     *
     * Parameter filePath of directory
     * Returns: true if the directory was created, false if not.
     * Throws: IO Errors
     */
    func createDirectoryIfNotExists(path url: URL) throws {
        if !fileExists(atPath: url) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true,
                                                    attributes: nil)
        }
    }

    /**
     * Deletes file or directory located at the following path.
     *
     * Parameter directoryPath path to directory to be deleted. Can't be ```nil```.
     * Throws: IOException read/write error occurred while accessing the file system.
     */
    func deleteEntityAtPath(path directoryPath: URL) throws {
        try FileManager.default.removeItem(atPath: directoryPath.path)
    }

    /**
     * Unzips the directory to the specified path,
     * and deletes the original archive.
     *
     * Parameter sourcePath: the path to the zipped.
     * Parameter destPath:  the parent directory where the unzipped folder will reside
     * Throws: Error if fails to unzip the directory or delete the original archive
     */
    func unzipDirectory(source sourcePath: URL, destination destPath: URL) throws {
        SSZipArchive.unzipFile(atPath: sourcePath.path, toDestination: destPath.path)
        //try Zip.unzipFile(sourcePath, destination: destPath, overwrite: true, password: nil)
        try deleteEntityAtPath(path: sourcePath)
    }

    /**
     * Copies the contents of one directory to another. Copies all the contents recursively.
     *
     * Parameter sourceDir path to the directory to copy files from.
     * Parameter destDir   path to the directory to copy files to.
     * Throws Error read/write error occurred while accessing the file system.
     */
    func copyDirectoryContents(fromSource sourceDir: URL, toDest destDir: URL) throws {
        try createDirectoryIfNotExists(path: destDir)

        let directoryContents = try FileManager.default.contentsOfDirectory(atPath: sourceDir.path)

        for item in directoryContents {
            let fullPath = appendPathComponent(atBasePath: sourceDir, withComponent: item)
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: fullPath.path, isDirectory: &isDir)
            if isDir.boolValue {
                try self.copyDirectoryContents(fromSource: fullPath,
                                               toDest: appendPathComponent(atBasePath: destDir,
                                                                           withComponent: item))
            } else {
                let destination = appendPathComponent(atBasePath: destDir, withComponent: item)
                if fileExists(atPath: destination) {
                    try deleteEntityAtPath(path: destination)
                }
                try copyFile(file: fullPath, toDestination: destination)
            }
        }
    }
}
