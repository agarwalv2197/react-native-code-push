//
//  CodePushDownloadPackageResult.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushDownloadPackageResult {
    
    /**
     * The file containing the update.
     */
    var downloadFile: String
    
    /**
     * Whether the file is zipped.
     */
    var isZip: Bool
    
    /**
     * Creates an instance of the class.
     *
     * @param downloadFile the file containing the update.
     * @param isZip        whether the file is zipped.
     */
    init(_ downloadFile: String, _ isZip: Bool) {
        self.downloadFile = downloadFile
        self.isZip = isZip
    }
}
