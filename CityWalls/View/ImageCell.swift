//
//  ImageCell.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
  
  let imageView: UIImageView
  
  override init(frame: CGRect) {
    self.imageView = .init()
    super.init(frame: frame)
    configureLayout()
    contentView.backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(imageView)
    activate(
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
    )
  }
  
}
