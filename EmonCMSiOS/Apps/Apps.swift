//
//  Apps.swift
//  EmonCMSiOS
//
//  Created by Matt Galloway on 31/12/2018.
//  Copyright © 2018 Matt Galloway. All rights reserved.
//

import UIKit

import RxSwift

protocol AppViewModel: AnyObject {

  init(account: Account, api: EmonCMSAPI, appDataId: String)

}

typealias AppUUIDAndCategory = (uuid: String, category: AppCategory)

enum AppCategory: String, CaseIterable {

  case myElectric
  case mySolar

  struct Info {
    let displayName: String
    let storyboardId: String
  }

  var info: Info {
    switch self {
    case .myElectric:
      return Info(
        displayName: "MyElectric",
        storyboardId: "myElectric"
      )
    case .mySolar:
      return Info(
        displayName: "MySolar",
        storyboardId: "mySolar"
      )
    }
  }

  var feedConfigFields: [AppConfigFieldFeed] {
    switch self {
    case .myElectric:
      return [
        AppConfigFieldFeed(id: "useFeedId", name: "Power Feed", optional: false, defaultName: "use"),
        AppConfigFieldFeed(id: "kwhFeedId", name: "kWh Feed", optional: false, defaultName: "use_kwh"),
      ]
    case .mySolar:
      return [
        AppConfigFieldFeed(id: "useFeedId", name: "Power Feed", optional: false, defaultName: "use"),
        AppConfigFieldFeed(id: "useKwhFeedId", name: "Power kWh Feed", optional: false, defaultName: "use_kwh"),
        AppConfigFieldFeed(id: "solarFeedId", name: "Solar Feed", optional: false, defaultName: "solar"),
        AppConfigFieldFeed(id: "solarKwhFeedId", name: "Solar kWh Feed", optional: false, defaultName: "solar_kwh"),
      ]
    }
  }

}
