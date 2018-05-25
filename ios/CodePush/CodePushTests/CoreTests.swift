//
//  CoreTests.swift
//  CodePushTests
//
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

    func testCheckForUpdate() {
        let codePushBuilder = CodePushBuilder()
        codePushBuilder.setDeploymentKey(key: "i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf")
        codePushBuilder.setAppName(name: "helloworld")
        codePushBuilder.setAppVersion(version: "1.0.0")
        let codePush = codePushBuilder.result()

        if codePush != nil {
            codePush!.checkForUpdate(callback: { result in
                do {
                    let remote = try result.resolve()
                    if remote == nil {
                        print("No Package Available")
                    } else {
                        print(remote?.downloadURL)
                    }
                } catch {
                    print(error)
                }
            })

            sleep(10)
        }
    }

    func testDownloadUpdate() {
        let codePushBuilder = CodePushBuilder()
        codePushBuilder.setDeploymentKey(key: "i4veHSlIOuyvuFKmGOD-Jcyp1uSXHkoQ4e-Tf")
        codePushBuilder.setAppName(name: "testapp")
        codePushBuilder.setAppVersion(version: "1.0.0")
        let codePush = codePushBuilder.result()

        if codePush != nil {
            codePush!.sync(callback: { result in
                do {
                    let didSync = try result.resolve()
                    print(didSync)
                } catch {
                    print(error)
                }
            })

            sleep(30)
        }
    }
}
