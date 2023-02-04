//
//  ConstructionYear.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation

enum ConstructionYear {
  case single(Date)
  case interval(Date, Date)
}

extension ConstructionYear: Codable {
  
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let firstDate = try container.decode(Date.self)
    let secondDate = try container.decodeIfPresent(Date.self)
    if let secondDate = secondDate {
      self = .interval(firstDate, secondDate)
    } else {
      self = .single(firstDate)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    switch self {
    case .single(let date):
      try container.encode(date)
    case .interval(let start, let end):
      try container.encode(start)
      try container.encode(end)
    }
  }
  
}

extension ConstructionYear: CustomStringConvertible {
  
  var description: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY"
    switch self {
    case .single(let year):
      return formatter.string(from: year)
    case .interval(let start, let end):
      return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
  }
  
}


