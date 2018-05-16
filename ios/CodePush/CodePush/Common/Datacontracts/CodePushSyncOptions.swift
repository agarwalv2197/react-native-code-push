//
//  CodePushSyncOptions.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushSyncOptions: Codable {
    
    /**
     * Specifies the deployment key you want to query for an update against.
     * By default, this value is derived from the MainActivity.java file (Android),
     * but this option allows you to override it from the script-side if you need to
     * dynamically use a different deployment for a specific call to sync.
     */
    var deploymentKey: String
    
    /**
     * Specifies when you would like to install optional updates (i.e. those that aren't marked as mandatory).
     * Defaults to {@link CodePushInstallMode#ON_NEXT_RESTART}.
     */
    var installMode: CodePushInstallMode
    
    /**
     * Specifies when you would like to install updates which are marked as mandatory.
     * Defaults to {@link CodePushInstallMode#IMMEDIATE}.
     */
    var mandatoryInstallMode: CodePushInstallMode;
    
    /**
     * Specifies the minimum number of seconds that the app needs to have been in the background before restarting the app.
     * This property only applies to updates which are installed using {@link CodePushInstallMode#ON_NEXT_RESUME},
     * and can be useful for getting your update in front of end users sooner, without being too obtrusive.
     * Defaults to `0`, which has the effect of applying the update immediately after a resume, regardless
     * how long it was in the background.
     */
    var minimumBackgroundDuration: Int
    
    /**
     * Specifies whether to ignore failed updates.
     * Defaults to <code>true</code>.
     */
    var ignoreFailedUpdates: Bool = true
    
    /**
     * An "options" object used to determine whether a confirmation dialog should be displayed to the end user when an update is available,
     * and if so, what strings to use. Defaults to null, which has the effect of disabling the dialog completely.
     * Setting this to any truthy value will enable the dialog with the default strings, and passing an object to this parameter allows
     * enabling the dialog as well as overriding one or more of the default strings.
     */
   // private CodePushUpdateDialog updateDialog;
    
    /**
     * Specifies when you would like to synchronize updates with the CodePush server.
     * Defaults to {@link CodePushCheckFrequency#ON_APP_START}.
     */
     var checkFrequency: CodePushCheckFrequency
    
    /**
     * Creates default instance of sync options.
     *
     * @param deploymentKey the deployment key you want to query for an update against.
     */
    init(_ deploymentKey: String) {
        self.deploymentKey = deploymentKey
        self.installMode = CodePushInstallMode.ON_NEXT_RESTART
        self.mandatoryInstallMode = CodePushInstallMode.IMMEDIATE
        self.minimumBackgroundDuration = 0
        self.ignoreFailedUpdates = true
        self.checkFrequency = CodePushCheckFrequency.ON_APP_START
    }
    
    convenience init() {
        self.init("")
    }
}
