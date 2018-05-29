//
//  CodePushDiffManifest.swift
//  Pods
//
//

import Foundation

/**
 * Represents the diff file that will be present on diff updates
 */
class CodePushDiffManifest: Codable {

    /**
     * The list of files to be removed from the current installation
     */
    var deletedFiles: [URL]
}
