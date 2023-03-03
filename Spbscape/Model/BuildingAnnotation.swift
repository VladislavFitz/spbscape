//
//  BuildingAnnotation.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import InstantSearchCore
import MapKit
import SpbscapeCore

class BuildingAnnotation: NSObject, MKAnnotation {
  let building: Building

  var coordinate: CLLocationCoordinate2D {
    return building.location
  }

  var title: String? {
    return building.titles.first
  }

  init(building: Building) {
    self.building = building
  }

  convenience init(buildingHit: Hit<Building>) {
    self.init(building: buildingHit.object)
  }

  override var hash: Int {
    return building.id.hashValue
  }

//  override func hash(into hasher: inout Hasher) {
//    hasher.combine(building.id)
//    super.hash(into: &hasher)
//  }
}
