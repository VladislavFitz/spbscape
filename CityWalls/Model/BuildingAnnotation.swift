//
//  BuildingAnnotation.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import MapKit
import CityWallsCore

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
  
  override var hash: Int {
    return building.id.hashValue
  }
  

//  override func hash(into hasher: inout Hasher) {
//    hasher.combine(building.id)
//    super.hash(into: &hasher)
//  }
  
}
