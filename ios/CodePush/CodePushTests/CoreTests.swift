//
//  CoreTests.swift
//  CodePushTests
//
//  Created by Chris Moulds on 5/15/18.
//  Copyright © 2018 MSFT. All rights reserved.
//

import XCTest

class CoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let codePush = CodePushBaseCore("i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf",
                                        "", true, "", "", "", "1",
                                        ReactPlatformUtils.sharedInstance)
        
        codePush.checkForUpdate(callback: { result in
            do {
                let remote = try result.resolve()
            } catch {
                print(error)
            }
        })
        sleep(4)
    }
    
}
