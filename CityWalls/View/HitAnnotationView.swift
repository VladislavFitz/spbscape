//
//  HitAnnotationView.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import MapKit
import AlgoliaSearchClient
import Geohash
import CityWallsCore

class HitAnnotationView: MKMarkerAnnotationView {
  
  internal override var annotation: MKAnnotation? {
    willSet {
      newValue.flatMap(configure(with:))
    }
  }
  var buildingViewController: BuildingViewController!
    
  func configure(with annotation: MKAnnotation) {
    guard annotation is BuildingAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
    markerTintColor = ColorScheme.tintColor
    glyphImage = UIImage(systemName: "building.2")
    clusteringIdentifier = String(describing: HitAnnotationView.self)
  }
  
}

class BuildingClusterAnnotation: NSObject, MKAnnotation {
  
  let count: Int
  let coordinate: CLLocationCoordinate2D
  
  init(coordinate: CLLocationCoordinate2D, count: Int) {
    self.coordinate = coordinate
    self.count = count
  }
  
  init(facet: Facet) {
    self.coordinate = CLLocationCoordinate2D(geohash: facet.value)
    self.count = facet.count
  }
  
}

class BuildingClusterAnnotationView: MKMarkerAnnotationView {
  
  internal override var annotation: MKAnnotation? {
    willSet {
      newValue.flatMap(configure(with:))
    }
  }

  func configure(with annotation: MKAnnotation) {
    guard let clusterAnnotation = annotation as? BuildingClusterAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
    markerTintColor = ColorScheme.tintColor
    glyphText = "\(clusterAnnotation.count)"
    clusteringIdentifier = String(describing: ClusterView.self)
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


