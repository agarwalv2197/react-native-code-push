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
    func fileExists(atPath filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    /**
     * Appends file path with one more component.
     *
     * @param basePath            path to be appended.
     * @param appendPathComponent path component to be appended to the base path.
     * @return new path.
     */
    func appendPathComponent(atBasePath basePath: String, withComponent appendPathComponent: String) -> String {
        let url = NSURL(string: basePath)
        let newUrl = url?.appendingPathComponent(appendPathComponent)
        return (newUrl?.absoluteString)!
    }
    
    /**
     * Writes some content to a file, existing file will be overwritten.
     *
     * @param content  content to be written to a file.
     * @param filePath path to a file.
     */
    func writeToFile(withContent content: String, atPath filePath: String) throws {
        try content.write(to: URL(fileURLWithPath: filePath), atomically: false, encoding: .utf8)
    }
    
    /**
     * Reads the contents of file to a string.
     *
     * @param filePath path to file to be read.
     * @return string with contents of the file.
     */
    func readFileToString(atPath filePath: String) throws -> String {
        return try String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8)
    }
    
    func moveFile(file origin: String, toDestination destination: String) throws {
        try FileManager.default.moveItem(at: URL(string: origin)!, to: URL(fileURLWithPath: destination))
    }
    
    /**
     * Creates a new directory if it doesn't already exist
     *
     * @param filePath of directory
     * @return true if the directory was created, false if not.
     * @throws
     */
    func createDirectoryIfNotExists(path url: String) throws {
        if (!fileExists(atPath: url)) {
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: url), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /**
     * Deletes directory located by the following path.
     *
     * @param directoryPath path to directory to be deleted. Can't be <code>null</code>.
     * @throws IOException read/write error occurred while accessing the file system.
     */
    func deleteDirectoryAtPath(path directoryPath: String) throws {
        if (directoryPath.isEmpty) {
            throw CodePushErrors.IOErrors
        } else {
            try FileManager.default.removeItem(atPath: directoryPath)
        }
    }
}
