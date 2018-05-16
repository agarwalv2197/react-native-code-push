//
//  CodePushUpdateUtils.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

class CodePushUpdateUtils {
    
    static let sharedInstance = CodePushUpdateUtils()
    let fileUtils: FileUtils
    let codePushUtils: CodePushUtils
    
    private init() {
        self.fileUtils = FileUtils.sharedInstance
        self.codePushUtils = CodePushUtils.sharedInstance
    }
    
    /**
     * Locates hash computed on bundle file that was generated during the app build.
     *
     * @param context     application context.
     * @param isDebugMode is application running in debug mode.
     * @return hash value.
     */
//    func getHashForBinaryContents(boolean isDebugMode) -> String? {
//    try {
//    return codePushUtils.getStringFromInputStream(context.getAssets().open(CodePushConstants.CODE_PUSH_HASH_FILE_NAME));
//    } catch (IOException e) {
//    try {
//    return codePushUtils.getStringFromInputStream(context.getAssets().open(CodePushConstants.CODE_PUSH_OLD_HASH_FILE_NAME));
//    } catch (IOException ex) {
//    if (!isDebugMode) {
//    
//    /* Only print this message in "Release" mode. In "Debug", we may not have the
//     * hash if the build skips bundling the files. */
//    throw new CodePushMalformedDataException("Unable to get the hash of the binary's bundled resources - \"codepush.gradle\" may have not been added to the build definition.", ex);
//    }
//    }
//    return null;
//    }
//    }

}
