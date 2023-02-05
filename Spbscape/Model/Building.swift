//
//  Building.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import CoreLocation

struct Building: Codable {
  
  let id: Int
  let title: String
  let location: CLLocationCoordinate2D
  let architects: [Component]
  let styles: [Component]
  let addresses: [Component]
  let constructionYears: [ConstructionYear]
  let photos: [Photo]
  
  struct Component: Codable {
    let id: Int
    let title: String
  }
  
}

extension Array where Element == Building {
  
  init(fileName: String) {
    self = Bundle.main
      .url(forResource: "hundredBuildings", withExtension: nil)
      .flatMap { try? Data.init(contentsOf: $0) }
      .flatMap { try? JSONDecoder().decode([Building].self, from: $0) } ?? []
  }

}

extension Building {
  
  var buildingURL: URL { URL(string: "https://www.citywalls.ru/house\(id).html")! }
  
}
