//
//  BuldingHitsMapViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import UIKit
import InstantSearch
import MapKit
import CityWallsCore

class BuldingHitsMapViewController: UIViewController, HitsController {
  
  let locationManager: CLLocationManager
  let mapView: MKMapView
  var hitsSource: HitsInteractor<Building>?
  var hashFacets: [Attribute: [Facet]]
  let userTrackingButton: MKUserTrackingButton

  private var isInitialMapFocusDone: Bool = false
  private var nextRegionChangeIsFromUserInteraction = false
  
  var didSelect: ((Building, MKAnnotationView) -> Void)?
  var didChangeVisibleRegion: ((MKMapRect) -> Void)? = nil
    
  init() {
    self.mapView = MKMapView()
    self.locationManager = .init()
    self.hashFacets = [:]
    self.userTrackingButton = MKUserTrackingButton(mapView: mapView)
    super.init(nibName: nil, bundle: nil)
    mapView.register(HitAnnotationView.self, forAnnotationViewWithReuseIdentifier: "buildingAnnotationView")
//    mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: "buildingClusterAnnotation")
    mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    let saintPetersburgCenterCoordinate = CLLocationCoordinate2D(latitude: 59.9411, longitude: 30.3009)
    mapView.setCamera(.init(lookingAtCenter: saintPetersburgCenterCoordinate, fromDistance: 20000, pitch: 0, heading: 0), animated: false)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()
    placeAnnotations()
    mapView.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startUpdatingLocation()
    mapView.showsUserLocation = true
    mapView.showsBuildings = true
    mapView.showsCompass = true
    
    mapView.addSubview(userTrackingButton)
    userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
    userTrackingButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    userTrackingButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -50).isActive = true
    userTrackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20).isActive = true
  }
  
  private func configureLayout() {
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)
    activate(
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
  }
   
  private func placeAnnotations() {
    let buildings = hitsSource?.getCurrentHits() ?? []
    
    let fetchedBuildingsIDs = Set(buildings.map(\.id))
    let presentedBuildingsIDs = Set(mapView.annotations.compactMap { $0 as? BuildingAnnotation }.map(\.building.id))
    let buildingIDsToKeep = fetchedBuildingsIDs.intersection(presentedBuildingsIDs)
    let buildingIDsToRemove = presentedBuildingsIDs.subtracting(buildingIDsToKeep)
    let buildingIDsToAdd = fetchedBuildingsIDs.subtracting(buildingIDsToKeep)
    
    let annotationsToRemove = mapView.annotations.compactMap { ($0 as? BuildingAnnotation)?.building.id }.filter(buildingIDsToRemove.contains)
    
    if !annotationsToRemove.isEmpty {
      mapView.removeAnnotations(mapView.annotations.compactMap { $0 as? BuildingAnnotation }.filter { annotationsToRemove.contains($0.building.id) })
    }
    
    let annotationsToAdd = buildings.filter { buildingIDsToAdd.contains($0.id) }.map(BuildingAnnotation.init)
    if !annotationsToAdd.isEmpty {
      mapView.addAnnotations(annotationsToAdd)
    }
    
//    print("Fetched buildings: \(fetchedBuildingsIDs.count)")
//    print("Presenting buildings: \(presentedBuildingsIDs.count)")
//    print("Buildings diff: \(buildingIDsToAdd.count)")
  }
      
  func reload() {
    placeAnnotations()
  }
  
  func scrollToTop() {
    
  }
  
  func highlight(_ building: Building) {
    guard let buildingAnnotation = mapView.annotations.first(where: { annotation in (annotation as? BuildingAnnotation)?.building.id == building.id
    }) else { return }
    mapView.showAnnotations([buildingAnnotation], animated: true)
    mapView.selectAnnotation(buildingAnnotation, animated: true)
  }
  
}

extension BuldingHitsMapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let buildingAnnotation = view.annotation as? BuildingAnnotation else { return }
//    mapView.setCenter(buildingAnnotation.coordinate, animated: true)
    didSelect?(buildingAnnotation.building, view)
  }
    
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
   
    // A hack which makes possible to determine if region was changed by user's gesture
    
    guard let mapGestureRecognizers = mapView.subviews.first?.gestureRecognizers else { return }
    
    for gestureRecognizer in mapGestureRecognizers {
      if [.began, .ended].contains(gestureRecognizer.state) {
        nextRegionChangeIsFromUserInteraction = true
        break
      }
    }
    
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
    if nextRegionChangeIsFromUserInteraction {
      nextRegionChangeIsFromUserInteraction = false
    }
    
//    if !isInitialMapFocusDone {
//      isInitialMapFocusDone = true
      didChangeVisibleRegion?(mapView.visibleMapRect)
//    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    switch annotation {
    case is BuildingAnnotation:
      return mapView.dequeueReusableAnnotationView(withIdentifier: "buildingAnnotationView", for: annotation)
//    case is MKClusterAnnotation:
//      return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
//    case is BuildingClusterAnnotation:
//      return mapView.dequeueReusableAnnotationView(withIdentifier: "buildingClusterAnnotation", for: annotation)
    default:
      return nil
    }
  }
  
}

extension BoundingBox {
  
  init(_ mapRect: MKMapRect) {
    let point1 = Point(mapRect.origin)
    let point2 = Point(MKMapPoint(x: mapRect.origin.x + mapRect.size.width,
                                  y: mapRect.origin.y + mapRect.size.height))
    self.init(point1: point1, point2: point2)
  }
  
}

extension Point {
  
  init(_ mapPoint: MKMapPoint) {
    self.init(latitude: mapPoint.coordinate.latitude, longitude: mapPoint.coordinate.longitude)
  }
  
}
