//
//  CodePushManagers.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


struct CodePushManagers {
    
    var updateManager: CodePushUpdateManager
    var acquisitionManager: CodePushAcquisitionManager
    var settingsManager: CodePushSettingsManager
    
    init (_ updateManager: CodePushUpdateManager, _ acquisitionManager: CodePushAcquisitionManager,
          _ settingsManager: CodePushSettingsManager) {
        self.updateManager = updateManager
        self.acquisitionManager = acquisitionManager
        self.settingsManager = settingsManager
    }
}
