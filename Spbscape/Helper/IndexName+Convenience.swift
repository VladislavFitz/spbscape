//
//  IndexName+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearchCore

extension IndexName {
  
  static var buildings: IndexName { "buildings" }
  static var streets: IndexName { "streets" }
  static var architects: IndexName { "architects" }
  static var styles: IndexName { "styles" }

}

struct SpbscapeCredentials {
  
  static var credentials: (appID: ApplicationID, APIKey: APIKey) = {
    guard let path = Bundle.main.path(forResource: "Credentials", ofType: "plist") else {
      assertionFailure("Credentials.plist not found")
      return ("", "")
    }
    guard let dictionary = NSDictionary(contentsOfFile: path) else {
      assertionFailure("Cannot build dictionary from Credentials.plist")
      return ("", "")
    }
    guard let rawAppID = dictionary.value(forKey: "AlgoliaApplicationID") as? String else {
      assertionFailure("Missing AlgoliaApplicationID value in Credentials.plist")
      return ("", "")
    }
    guard let rawAPIKey = dictionary.value(forKey: "AlgoliaAPIKey") as? String else {
      assertionFailure("Missing AlgoliaAPIKey value in Credentials.plist")
      return ("", "")
    }
    return (ApplicationID(rawValue: rawAppID), APIKey(rawValue: rawAPIKey))
  }()

}

extension ApplicationID {
  static let spbscapeAppID: ApplicationID = SpbscapeCredentials.credentials.appID
}

extension APIKey {
  static let spbscape: APIKey = SpbscapeCredentials.credentials.APIKey
}

extension String {

  init?(environmentVariable: String) {
    if
      let rawValue = getenv(environmentVariable),
      let value = String(utf8String: rawValue) {
      self = value
    } else {
      return nil
    }
  }

}
