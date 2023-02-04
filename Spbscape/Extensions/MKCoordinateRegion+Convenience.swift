//
//  MKCoordinateRegion+Convenience.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
  
  var sizeInMeters: (h: Int, v: Int) {
    let deltaLatitude = span.latitudeDelta
    let deltaLongitude = span.latitudeDelta
    let latitudeCircumference = 40075160 * cos(center.latitude * Double.pi / 180)
    let verticalInMeters = Int(deltaLatitude * 40008000 / 360)
    let horizontalInMeters = Int(deltaLongitude * latitudeCircumference / 360)
    return (horizontalInMeters, verticalInMeters)
  }
  
}

