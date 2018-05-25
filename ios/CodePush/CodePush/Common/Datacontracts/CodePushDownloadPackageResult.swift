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
    var downloadFile: URL

    /**
     * Whether the file is zipped.
     */
    var isZip: Bool

    /**
     * Creates an instance of the class.
     *
     * Parameter downloadFile the file containing the update.
     * Parameter isZip        whether the file is zipped.
     */
    init(_ downloadFile: URL, _ isZip: Bool) {
        self.downloadFile = downloadFile
        self.isZip = isZip
    }
}
