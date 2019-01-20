//
//  EmonCMSiOSUITests.swift
//  EmonCMSiOSUITests
//
//  Created by Matt Galloway on 20/01/2019.
//  Copyright © 2019 Matt Galloway. All rights reserved.
//

import Quick
import Nimble
@testable import EmonCMSiOS

class EmonCMSiOSUITests: QuickSpec {

  override func setUp() {
    super.setUp()
    self.continueAfterFailure = false
  }

  override func spec() {
    var app: XCUIApplication!

    beforeEach {
      app = XCUIApplication()
      app.launchArguments.append("--uitesting")
      app.launch()
    }

    func loginFromAccountList(name: String, url: String, apiKey: String) {
      app.navigationBars["Accounts"].buttons["Add"].tap()

      let tablesQuery = app.tables
      tablesQuery/*@START_MENU_TOKEN@*/.textFields["Emoncms instance name"]/*[[".cells.textFields[\"Emoncms instance name\"]",".textFields[\"Emoncms instance name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.typeText(name)
      tablesQuery/*@START_MENU_TOKEN@*/.textFields["Emoncms instance URL"]/*[[".cells.textFields[\"Emoncms instance URL\"]",".textFields[\"Emoncms instance URL\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.typeText(url)
      tablesQuery/*@START_MENU_TOKEN@*/.textFields["Emoncms API read Key"]/*[[".cells.textFields[\"Emoncms API read Key\"]",".textFields[\"Emoncms API read Key\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      app.typeText(apiKey)

      app.navigationBars["Account Details"].buttons["Save"].tap()
    }

    func loginFromAccountListWithValidCredentials() {
      loginFromAccountList(name: "Test Instance", url: "https://localhost", apiKey: "ilikecats")
    }

    describe("accounts") {
      it("should show empty accounts screen") {
        expect(app.tables[AccessibilityIdentifiers.Lists.Account].exists).to(equal(true))
        expect(app.tables[AccessibilityIdentifiers.Lists.Account].cells.count).to(equal(0))
        let addAccountLabel = app.staticTexts["Tap + to add a new account"]
        expect(addAccountLabel.exists).to(equal(true))
      }

      it("should add account successfully for valid details") {
        loginFromAccountListWithValidCredentials()
        expect(app.tables[AccessibilityIdentifiers.Lists.App].waitForExistence(timeout: 1)).to(equal(true))
      }

      it("should error for invalid credentials") {
        loginFromAccountList(name: "Test Instance", url: "https://localhost", apiKey: "notthekey")
        expect(app.alerts["Error"].exists).to(equal(true))
      }
    }

    describe("apps") {
      it("should show empty apps screen") {
        loginFromAccountListWithValidCredentials()
        expect(app.tables[AccessibilityIdentifiers.Lists.App].waitForExistence(timeout: 1)).to(equal(true))
        expect(app.tables[AccessibilityIdentifiers.Lists.App].cells.count).to(equal(0))
        let addAppLabel = app.staticTexts["Tap + to add a new app"]
        expect(addAppLabel.exists).to(equal(true))
      }

      it("should add app successfully") {
        loginFromAccountListWithValidCredentials()
        expect(app.tables[AccessibilityIdentifiers.Lists.App].waitForExistence(timeout: 1)).to(equal(true))
        app.navigationBars["Apps"].buttons["Add"].tap()
      }
    }
  }

}
