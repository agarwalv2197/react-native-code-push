//
//  CodePushUtilities.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushUtilities {

    /**
     * Instance of {@link CodePushUtils}.
     */
    var utils: CodePushUtils
    
    /**
     * Instance of {@link FileUtils}.
     */
    var fileUtils: FileUtils
    
    /**
     * Instance of {@link CodePushUpdateUtils}.
     */
    var updateUtils: CodePushUpdateUtils
    
    /**
     * Instance of {@link CodePushPlatformUtils}.
     */
    var platformUtils: CodePushPlatformUtils
    
    init(_ utils: CodePushUtils, _ fileUtils: FileUtils, _ updateUtils: CodePushUpdateUtils, _ platformUtils: CodePushPlatformUtils) {
        self.utils = utils
        self.fileUtils = fileUtils
        self.updateUtils = updateUtils
        self.platformUtils = platformUtils
    }
}
