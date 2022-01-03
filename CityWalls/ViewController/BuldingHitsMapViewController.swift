//
//  BuldingHitsMapViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import UIKit
import InstantSearchCore
import MapKit
import CityWallsCore

class BuldingHitsMapViewController: UIViewController, HitsController {
  
  let locationManager: CLLocationManager
  let mapView: MKMapView
  var hitsSource: HitsInteractor<Hit<Building>>?
  var hashFacets: [Attribute: [Facet]]
  let userTrackingButton: MKUserTrackingButton
  
  var window: UIWindow?
  
  var detailsTransitioningDelegate: TransitioningDelegate!

  private var nextRegionChangeIsFromUserInteraction = false
  
  var didSelect: ((Building, MKAnnotationView) -> Void)?
  var didChangeVisibleRegion: ((MKMapRect, Bool) -> Void)? = nil
    
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
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
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
    
    let fetchedBuildingsIDs = Set(buildings.map(\.object.id))
    let presentedBuildingsIDs = Set(mapView.annotations.compactMap { $0 as? BuildingAnnotation }.map(\.building.id))
    let buildingIDsToKeep = fetchedBuildingsIDs.intersection(presentedBuildingsIDs)
    let buildingIDsToRemove = presentedBuildingsIDs.subtracting(buildingIDsToKeep)
    let buildingIDsToAdd = fetchedBuildingsIDs.subtracting(buildingIDsToKeep)
    
    let annotationsToRemove = mapView.annotations.compactMap { ($0 as? BuildingAnnotation)?.building.id }.filter(buildingIDsToRemove.contains)
    
    if !annotationsToRemove.isEmpty {
      mapView.removeAnnotations(mapView.annotations.compactMap { $0 as? BuildingAnnotation }.filter { annotationsToRemove.contains($0.building.id) })
    }
    
    let annotationsToAdd = buildings.filter { buildingIDsToAdd.contains($0.object.id) }.map(BuildingAnnotation.init)
    if !annotationsToAdd.isEmpty {
      mapView.addAnnotations(annotationsToAdd)
    }
  }
      
  func reload() {
    placeAnnotations()
  }
  
  func scrollToTop() {
    
  }
  
  @objc func didTap() {
    if let presentedViewController = presentedViewController {
      presentedViewController.dismiss(animated: true, completion: nil)
    }
  }

  
  func isVisible(_ building: Building) -> Bool {
    return mapView.annotations.contains(where: { annotation in (annotation as? BuildingAnnotation)?.building.id == building.id })
  }
  
  func highlight(_ building: Building, completion: @escaping () -> Void = {}) {
    guard let buildingAnnotation = mapView.annotations.first(where: { annotation in (annotation as? BuildingAnnotation)?.building.id == building.id
    }) else { return }
    
    MKMapView.animate(withDuration: 1) { [weak mapView] in
      guard let mapView = mapView else { return }
      if !mapView.visibleMapRect.contains(MKMapPoint(buildingAnnotation.coordinate)) {
        mapView.setCenter(buildingAnnotation.coordinate, animated: true)
      }
    } completion: { [weak mapView] _ in
      guard let mapView = mapView else { return }
      mapView.selectAnnotation(buildingAnnotation, animated: true)
      completion()
    }
  }
  
}

extension BuldingHitsMapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let buildingAnnotation = view.annotation as? BuildingAnnotation else { return }
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
    
    didChangeVisibleRegion?(mapView.visibleMapRect, nextRegionChangeIsFromUserInteraction)
    
    if nextRegionChangeIsFromUserInteraction {
      nextRegionChangeIsFromUserInteraction = false
    }

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

extension BuldingHitsMapViewController {
  
  func presentPopover(for building: Building, from annotation: MKAnnotationView) {
    let buildingViewController = BuildingViewController(building: building)
    let item = UIBarButtonItem(image: UIImage(systemName: "arrow.up.left.and.arrow.down.right"), style: .done, target: self, action: #selector(tryFullscreen))
    buildingViewController.navigationItem.rightBarButtonItem = item
    let navigationController = UINavigationController(rootViewController: buildingViewController)
    navigationController.preferredContentSize = .init(width: 300, height: 320)
    navigationController.modalPresentationStyle = .popover
    navigationController.popoverPresentationController?.sourceView = annotation
    navigationController.popoverPresentationController?.sourceRect = annotation.bounds.insetBy(dx: annotation.calloutOffset.x - 20, dy: annotation.calloutOffset.y - 20)
    present(navigationController, animated: true, completion: nil)
  }
  
  @objc func tryFullscreen() {
    
    if let navigationController = presentedViewController as? UINavigationController, navigationController.viewControllers.first is BuildingViewController, navigationController.modalPresentationStyle == .popover {
      navigationController.dismiss(animated: true) {
        let dismissBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(self.dismissFullscreen))
        navigationController.viewControllers.first?.navigationItem.rightBarButtonItem = dismissBarButtonItem
        navigationController.viewControllers.first?.preferredContentSize = CGSize(width: 500, height: 700)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: true, completion: nil)
      }
    }
  }
  
  @objc func dismissFullscreen() {
    if let navigationController = presentedViewController as? UINavigationController, navigationController.viewControllers.first is BuildingViewController, navigationController.modalPresentationStyle == .formSheet {
      navigationController.dismiss(animated: true, completion: nil)
    }
  }
  
}
