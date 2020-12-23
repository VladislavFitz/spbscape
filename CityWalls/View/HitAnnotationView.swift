//
//  HitAnnotationView.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import MapKit
import CityWallsCore

class HitAnnotationView: MKMarkerAnnotationView {
  
  internal override var annotation: MKAnnotation? {
    willSet {
      newValue.flatMap(configure(with:))
    }
  }
  
  func configure(with annotation: MKAnnotation) {
    guard annotation is BuildingAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
    
    markerTintColor = .systemTeal
    glyphImage = UIImage(systemName: "building.2")
    clusteringIdentifier = String(describing: HitAnnotationView.self)
  }
  
}

final class HitMKAnnotationDecorator: NSObject, MKAnnotation {
  
  let hit: Building
  
  var coordinate: CLLocationCoordinate2D {
    return hit.location
  }
  
  var title: String? {
    return hit.titles.first
  }
  
  var subtitle: String? {
    return nil
  }
  
  init(hit: Building) {
    self.hit = hit
  }
  
}


