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
     * Size of the buffer used when writing to files.
     */
    private let WRITE_BUFFER_SIZE = 1024 * 8
    
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
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filePath)
        
            //writing
            do {
                try content.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    /**
     * Reads the contents of file to a string.
     *
     * @param filePath path to file to be read.
     * @return string with contents of the file.
     */
    func readFileToString(atPath filePath: String) throws -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filePath)
            
            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                return content
            }
            catch {/* error handling here */}
        } else {fatalError("Cannot read file")}
        
        return ""
    }
    
    /**
     * Deletes directory located by the following path.
     *
     * @param directoryPath path to directory to be deleted. Can't be <code>null</code>.
     * @throws IOException read/write error occurred while accessing the file system.
     */
    func deleteDirectoryAtPath(path directoryPath: String) throws {
        if (directoryPath.isEmpty) {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: directoryPath)
        } catch {
        
        }
    }
}
