//
//  DashboardUpdateHelperTests.swift
//  EmonCMSiOSTests
//
//  Created by Matt Galloway on 24/01/2019.
//  Copyright © 2019 Matt Galloway. All rights reserved.
//

import Combine
@testable import EmonCMSiOS
import EntwineTest
import Nimble
import Quick
import Realm
import RealmSwift

class DashboardUpdateHelperTests: EmonCMSTestCase {
  override func spec() {
    var realmController: RealmController!
    var accountController: AccountController!
    var realm: Realm!
    var requestProvider: MockHTTPRequestProvider!
    var api: EmonCMSAPI!
    var viewModel: DashboardUpdateHelper!
    var cancellables: Set<AnyCancellable> = []

    beforeEach {
      realmController = RealmController(dataDirectory: self.dataDirectory)
      let credentials = AccountCredentials(url: "https://test", apiKey: "ilikecats")
      accountController = AccountController(uuid: "testaccount-\(type(of: self))", credentials: credentials)
      realm = realmController.createAccountRealm(forAccountId: accountController.uuid)
      try! realm.write {
        realm.deleteAll()
      }

      requestProvider = MockHTTPRequestProvider()
      api = EmonCMSAPI(requestProvider: requestProvider)
      viewModel = DashboardUpdateHelper(realmController: realmController, account: accountController, api: api)
      cancellables.removeAll()
    }

    describe("dashboardHandling") {
      it("should update dashboards") {
        waitUntil { done in
          let cancellable = viewModel.updateDashboards()
            .sink(
              receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let error):
                  fail(error.localizedDescription)
                }
                done()
              },
              receiveValue: { _ in })
          cancellables.insert(cancellable)
        }

        let results = realm.objects(Dashboard.self)
        expect(results.count).toEventually(equal(2))
      }

      it("should delete missing dashboards") {
        let newDashboardId = "differentId"

        try! realm.write {
          let dashboard = Dashboard()
          dashboard.id = newDashboardId
          realm.add(dashboard)
        }

        waitUntil { done in
          let cancellable = viewModel.updateDashboards()
            .sink(
              receiveCompletion: { completion in
                switch completion {
                case .finished:
                  break
                case .failure(let error):
                  fail(error.localizedDescription)
                }
                done()
              },
              receiveValue: { _ in })
          cancellables.insert(cancellable)
        }

        expect { realm.object(ofType: Dashboard.self, forPrimaryKey: newDashboardId) }
          .toEventually(beNil())
      }
    }
  }
}
