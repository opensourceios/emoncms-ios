//
//  MyElectricAppConfigViewModel.swift
//  EmonCMSiOS
//
//  Created by Matt Galloway on 13/10/2016.
//  Copyright © 2016 Matt Galloway. All rights reserved.
//

import Foundation

import RxSwift
import RealmSwift

final class MyElectricAppConfigViewModel: AppConfigViewModel {

  enum SaveError: Error {
    case missingFields([AppConfigField])
  }

  private let account: Account
  private let api: EmonCMSAPI
  private let realm: Realm
  private let appData: AppData

  lazy var feedListHelper: FeedListHelper = {
    return FeedListHelper(account: self.account, api: self.api)
  }()

  init(account: Account, api: EmonCMSAPI, appDataId: String?) {
    self.account = account
    self.api = api
    self.realm = account.createRealm()
    if let appDataId = appDataId {
      self.appData = self.realm.object(ofType: AppData.self, forPrimaryKey: appDataId)!
    } else {
      self.appData = AppData()
      self.appData.appCategory = .myElectric
    }
  }

  private enum ConfigKeys: String {
    case name
    case useFeedId
    case kwhFeedId
  }

  func configFields() -> [AppConfigField] {
    return [
      AppConfigFieldString(id: "name", name: "Name", optional: false),
      AppConfigFieldFeed(id: "useFeedId", name: "Power Feed", optional: false, defaultName: "use"),
      AppConfigFieldFeed(id: "kwhFeedId", name: "kWh Feed", optional: false, defaultName: "use_kwh"),
    ]
  }

  func configData() -> [String:Any] {
    var data: [String:Any] = [:]

    data[ConfigKeys.name.rawValue] = self.appData.name
    if let feedId = self.appData.feed(forName: "use") {
      data[ConfigKeys.useFeedId.rawValue] = feedId
    }
    if let feedId = self.appData.feed(forName: "kwh") {
      data[ConfigKeys.kwhFeedId.rawValue] = feedId
    }

    return data
  }

  func updateWithConfigData(_ data: [String:Any]) -> Observable<AppUUIDAndCategory> {
    return Observable.create { [weak self] observer in
      guard let strongSelf = self else { return Disposables.create() }

      // Validate first
      var missingFields: [AppConfigField] = []
      for field in strongSelf.configFields() where field.optional == false {
        if data[field.id] == nil {
          missingFields.append(field)
        }
      }

      if missingFields.count > 0 {
        observer.onError(SaveError.missingFields(missingFields))
      } else {
        do {
          let appData = strongSelf.appData
          try strongSelf.realm.write {
            if let name = data[ConfigKeys.name.rawValue] as? String {
              appData.name = name
            }
            if let feedId = data[ConfigKeys.useFeedId.rawValue] as? String {
              appData.setFeed(feedId, forName: "use")
            }
            if let feedId = data[ConfigKeys.kwhFeedId.rawValue] as? String {
              appData.setFeed(feedId, forName: "kwh")
            }

            if appData.realm == nil {
              strongSelf.realm.add(appData)
            }
          }
          observer.onNext((strongSelf.appData.uuid, strongSelf.appData.appCategory))
          observer.onCompleted()
        } catch {
          observer.onError(error)
        }
      }

      return Disposables.create()
    }
  }
  
}
