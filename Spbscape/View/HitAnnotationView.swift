//
//  HitAnnotationView.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import AlgoliaSearchClient
import Foundation
import Geohash
import MapKit
import SpbscapeCore

class HitAnnotationView: MKMarkerAnnotationView {
  override internal var annotation: MKAnnotation? {
    willSet {
      newValue.flatMap(configure(with:))
    }
  }

  func configure(with annotation: MKAnnotation) {
    guard annotation is BuildingAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
    markerTintColor = ColorScheme.primaryColor
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
    coordinate = CLLocationCoordinate2D(geohash: facet.value)
    count = facet.count
  }
}

class BuildingClusterAnnotationView: MKMarkerAnnotationView {
  override internal var annotation: MKAnnotation? {
    willSet {
      newValue.flatMap(configure(with:))
    }
  }

  func configure(with annotation: MKAnnotation) {
    guard let clusterAnnotation = annotation as? BuildingClusterAnnotation else { fatalError("Unexpected annotation type: \(annotation)") }
    markerTintColor = ColorScheme.primaryColor
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
