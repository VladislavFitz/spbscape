//
//  ImageCell.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
  let imageView: UIImageView

  override init(frame: CGRect) {
    imageView = UIImageView(autolayout: ())
    super.init(frame: frame)
    configureLayout()
    contentView.backgroundColor = .clear
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  private func configureLayout() {
    imageView.clipsToBounds = true
    contentView.addSubview(imageView)
    activate(
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    )
  }
}
