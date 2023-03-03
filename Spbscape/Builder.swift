//
//  Builder.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation

public protocol Builder {}

public extension Builder {
  func set<T>(_ keyPath: WritableKeyPath<Self, T>, to newValue: T) -> Self {
    var copy = self
    copy[keyPath: keyPath] = newValue
    return copy
  }

  func setIfNotNil<T>(_ keyPath: WritableKeyPath<Self, T>, to newValue: T?) -> Self {
    guard let value = newValue else { return self }
    var copy = self
    copy[keyPath: keyPath] = value
    return copy
  }
}
