//
//  SceneDelegate.swift
//  EmonCMSiOS
//
//  Created by Matt Galloway on 14/08/2019.
//  Copyright © 2019 Matt Galloway. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  #if DEBUG
    private static func isRunningTests() -> Bool {
      return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private static func isRunningUITests() -> Bool {
      return CommandLine.arguments.contains("--uitesting")
    }

  #else
    private static func isRunningTests() -> Bool { return false }
    private static func isRunningUITests() -> Bool { return false }
  #endif

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let runningTests = SceneDelegate.isRunningTests()
    let runningUITests = SceneDelegate.isRunningUITests()

    if runningTests, !runningUITests {
      // Skip initialising the UI if running unit tests
      return
    }

    let dataDirectory: URL
    let requestProvider: HTTPRequestProvider
    if runningUITests {
      UIView.setAnimationsEnabled(false)
      dataDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("uitests")
      try? FileManager.default.removeItem(at: dataDirectory)
      try! FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true, attributes: nil)

      let config = FakeHTTPProvider.Config(
        startTime: Date(timeIntervalSinceNow: -3600 * 24),
        feeds: [
          FakeHTTPProvider.Config.Feed(id: "1", name: "use", tag: "Node 5", interval: 10, kwhFeed: ("2", "use_kwh")),
          FakeHTTPProvider.Config
            .Feed(id: "3", name: "solar", tag: "Node 5", interval: 10, kwhFeed: ("4", "solar_kwh")),
          FakeHTTPProvider.Config
            .Feed(id: "5", name: "immersion", tag: "Node 5", interval: 10, kwhFeed: ("6", "immersion_kwh"))
        ])
      requestProvider = FakeHTTPProvider(config: config)
    } else {
      dataDirectory = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.SharedApplicationGroupIdentifier)!
      requestProvider = NSURLSessionHTTPRequestProvider()
    }

    let api = EmonCMSAPI(requestProvider: requestProvider)
    let realmController = RealmController(dataDirectory: dataDirectory)

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let rootViewController = storyboard.instantiateInitialViewController() as! UINavigationController

    let accountListViewController = rootViewController.topViewController! as! AccountListViewController
    accountListViewController.viewModel = AccountListViewModel(realmController: realmController, api: api)

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
  }
}
