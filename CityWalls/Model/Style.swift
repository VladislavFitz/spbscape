//
//  Style.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 18/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation

struct Style: Codable {
  let id: Int
  let name: String
}

extension Style: CustomStringConvertible {
  
  var description: String { name }
  
}
