//
//  ClusterView.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 08/11/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import MapKit

internal final class ClusterView: MKAnnotationView {
  
  internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    displayPriority = .defaultHigh
    collisionMode = .circle
    centerOffset = CGPoint(x: 0.0, y: -10.0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("\(#function) not implemented.")
  }
  
}

private extension ClusterView {
  
  func configure(with annotation: MKAnnotation) {
    
    
    let count: Int
    let color: UIColor

//    guard let annotation = annotation as? MKClusterAnnotation else { return }
    switch annotation {
    case let clusterAnnotation as MKClusterAnnotation:
      count = clusterAnnotation.memberAnnotations.count
      color = .systemTeal
    case let buildingClusterAnnotation as BuildingClusterAnnotation:
      count = buildingClusterAnnotation.count
      color = .systemTeal
    default:
      return
    }
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40.0, height: 40.0))
//    let count = annotation.memberAnnotations.count
    
    image = renderer.image { _ in
      color.setFill()
      UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)).fill()
      let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 20.0)]
      let text = "\(count)"
      let size = text.size(withAttributes: attributes)
      let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
      text.draw(in: rect, withAttributes: attributes)
    }
    
  }
}


