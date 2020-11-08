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
    return building.title
  }
  
  init(building: Building) {
    self.building = building
  }
  
}
