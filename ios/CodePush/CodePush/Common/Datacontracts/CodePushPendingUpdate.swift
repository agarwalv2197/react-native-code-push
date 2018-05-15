//
//  CodePushPendingUpdate.swift
//  CodePush
//
//  Copyright © 2018 MSFT. All rights reserved.
//

import Foundation


class CodePushPendingUpdate {
    
    /**
     * Whether the update is loading.
     */
    var pendingUpdateIsLoading: Bool?
    
    /**
     * Pending update package hash.
     */
    var pendingUpdateHash: String?
    
    init() {}
    
}
