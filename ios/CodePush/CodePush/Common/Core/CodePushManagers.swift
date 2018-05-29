//
//  CodePushManagers.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation

/**
 * Encapsulates managers that ```CodePushBaseCore``` is using.
 */
struct CodePushManagers {

    /**
     * Instance of ```CodePushUpdateManager```
     */
    var updateManager: CodePushUpdateManager
    
    /**
     * Instance of ```CodePushAcquisitionManager```
     */
    var acquisitionManager: CodePushAcquisitionManager
    
    /**
     * Instance of ```CodePushSettingsManager```
     */
    var settingsManager: CodePushSettingsManager

    /**
     * Creates instance of ```CodePushManagers```
     */
    init (_ updateManager: CodePushUpdateManager, _ acquisitionManager: CodePushAcquisitionManager,
          _ settingsManager: CodePushSettingsManager) {
        self.updateManager = updateManager
        self.acquisitionManager = acquisitionManager
        self.settingsManager = settingsManager
    }
}
