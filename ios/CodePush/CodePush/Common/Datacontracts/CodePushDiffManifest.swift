//
//  CodePushDiffManifest.swift
//  Pods
//
//

import Foundation

class CodePushDiffManifest: Codable {

    /**
     * The list of files to be removed from the current installation
     */
    var deletedFiles: [URL]
}
