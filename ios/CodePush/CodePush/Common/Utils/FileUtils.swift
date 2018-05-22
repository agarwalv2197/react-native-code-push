//
//  FileUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class FileUtils {
    
    static let sharedInstance = FileUtils()
    private init() {}
    
    /**
     * Checks whether a file by the following path exists.
     *
     * @param filePath path to be checked.
     * @return <code>true</code> if exists, <code>false</code> otherwise.
     */
    func fileExists(atPath filePath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: filePath.relativePath)
    }
    
    /**
     * Appends file path with one more component.
     *
     * @param basePath            path to be appended.
     * @param appendPathComponent path component to be appended to the base path.
     * @return new path.
     */
    func appendPathComponent(atBasePath basePath: URL, withComponent appendPathComponent: String) -> URL {
        return basePath.appendingPathComponent(appendPathComponent)
    }
    
    /**
     * Writes some content to a file, existing file will be overwritten.
     *
     * @param content  content to be written to a file.
     * @param filePath path to a file.
     */
    func writeToFile(withContent content: String, atPath filePath: URL) throws {
        try content.write(to: filePath, atomically: false, encoding: .utf8)
    }
    
    /**
     * Reads the contents of file to a string.
     *
     * @param filePath path to file to be read.
     * @return string with contents of the file.
     */
    func readFileToString(atPath filePath: URL) throws -> String {
        return try String(contentsOf: filePath, encoding: .utf8)
    }
    
    /**
     * Move a file to a destination
     *
     * @param origin the original location of the file
     * @param destination path of the file
     * @throws if the file already exists at the destination or due to IO errors.
     */
    func moveFile(file origin: URL, toDestination destination: URL) throws {
        try FileManager.default.moveItem(at: origin, to: destination)
    }
    
    /**
     * Creates a new directory if it doesn't already exist
     *
     * @param filePath of directory
     * @return true if the directory was created, false if not.
     * @throws
     */
    func createDirectoryIfNotExists(path url: URL) throws {
        if (!fileExists(atPath: url)) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /**
     * Deletes directory located by the following path.
     *
     * @param directoryPath path to directory to be deleted. Can't be <code>null</code>.
     * @throws IOException read/write error occurred while accessing the file system.
     */
    func deleteDirectoryAtPath(path directoryPath: URL?) throws {
        if (directoryPath == nil) {
            throw CodePushErrors.IOErrors
        } else {
            try FileManager.default.removeItem(atPath: directoryPath!.path)
        }
    }
}
