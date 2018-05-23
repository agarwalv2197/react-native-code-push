//
//  CodePushSyncOptions.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


public class CodePushSyncOptions: Codable {
    
    /**
     * Specifies the deployment key you want to query for an update against.
     */
    var deploymentKey: String
    
    /**
     * Specifies when you would like to install optional updates (i.e. those that aren't marked as mandatory).
     * Defaults to ```CodePushInstallMode.OnNextRestart```
     */
    var installMode: CodePushInstallMode?
    
    /**
     * Specifies when you would like to install updates which are marked as mandatory.
     * Defaults to ```CodePushInstallMode.Immediate```.
     */
    var mandatoryInstallMode: CodePushInstallMode?
    
    /**
     * Specifies the minimum number of seconds that the app needs to have been in the background before restarting the app.
     * This property only applies to updates which are installed using ```CodePushInstallMode.OnNextResume```,
     * and can be useful for getting your update in front of end users sooner, without being too obtrusive.
     * Defaults to `0`, which has the effect of applying the update immediately after a resume, regardless
     * how long it was in the background.
     */
    var minimumBackgroundDuration: Int?
    
    /**
     * Specifies whether to ignore failed updates.
     * Defaults to ```true```.
     */
    var ignoreFailedUpdates: Bool? = true
    
    /**
     * Specifies when you would like to synchronize updates with the CodePush server.
     * Defaults to ```CodePushCheckFrequency.OnAppStart```
     */
     var checkFrequency: CodePushCheckFrequency?
    
    /**
     * Creates default instance of sync options.
     *
     * Parameter deploymentKey the deployment key you want to query for an update against.
     */
    init(_ deploymentKey: String) {
        self.deploymentKey = deploymentKey
        self.installMode = .OnNextRestart
        self.mandatoryInstallMode = .Immediate
        self.minimumBackgroundDuration = 0
        self.ignoreFailedUpdates = true
        self.checkFrequency = .OnAppStart
    }
    
    convenience init() {
        self.init("")
    }
}
