//
//  CodePushConstants.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

struct CodePushConstants {
    
    /**
     * Default app name if not provided when building CodePush instance.
     */
    static let CodePushDefaultAppName = "CodePush"
    
    /**
     * Root folder name inside each update.
     */
    static let CodePushFolderPrefix = "CodePush"
    
    /**
     * Key for getting hash file for binary contents from assets folder.
     */
    static let CodePushHashFileName = "CodePushHash"
    
    /**
     * URL of the CodePush server
     */
    static let CodePushServer = "codepush.azurewebsites.net"
    
    /**
     * Name of the file containing information about the available packages.
     */
    static let StatusFileName = "codepush.json"
    
    /**
     * Package file name to store CodePush update metadata file.
     */
    static let PackageFileName = "app.json"
    
    /**
     * Package file name to store CodePush update metadata file.
     */
    static let ZipFileName = "download.zip"
    
    /**
     * File name for diff manifest that distributes with CodePush updates.
     */
    static let DiffManifestFileName = "hotcodepush.json"
    
    /**
     * Folder name for unzipped CodePush update.
     */
    static let UnzippedFolderName = "unzipped"
}
