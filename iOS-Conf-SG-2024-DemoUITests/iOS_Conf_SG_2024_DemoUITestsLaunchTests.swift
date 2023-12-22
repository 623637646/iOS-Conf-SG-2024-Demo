//
//  iOS_Conf_SG_2024_DemoUITestsLaunchTests.swift
//  iOS-Conf-SG-2024-DemoUITests
//
//  Created by Wang Ya on 22/12/23.
//

import XCTest

final class iOS_Conf_SG_2024_DemoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
