//
//  BuildingViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 19/04/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
import CityWallsCore

class BuildingViewController: UIViewController {
  
  let building: Building
  
  let titleLabel: UILabel
  let galleryViewController: GalleryViewController
  let goToCityWallsButton: UIButton
  
  init(building: Building) {
    self.building = building
    self.titleLabel = .init()
    self.galleryViewController = .init(images: building.photos.map(\.url))
    self.goToCityWallsButton = .init()
    super.init(nibName: nil, bundle: nil)
    titleLabel.text = building.titles.joined(separator: ", ")
    titleLabel.font = .systemFont(ofSize: 28, weight: .heavy)
    titleLabel.numberOfLines = 0
    configureLayout()
    addChild(galleryViewController)
    galleryViewController.willMove(toParent: self)
    galleryViewController.view.translatesAutoresizingMaskIntoConstraints = false
    configureButton()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureLayout() {
    
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundView)
    activate(
      backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 10
    stackView.distribution = .equalSpacing
    view.addSubview(stackView)
    
    galleryViewController.pageControl.hidesForSinglePage = true
    galleryViewController.pageControl.pageIndicatorTintColor = .lightGray
    galleryViewController.pageControl.currentPageIndicatorTintColor = .black

    galleryViewController.pageControl.layer.masksToBounds = true
    galleryViewController.pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(galleryViewController.view)
    stackView.addArrangedSubview(galleryViewController.pageControl)
    [
      ("Расположение:", building.addresses.map(\.description)),
      ("Архитекторы:", building.architects.map(\.title)),
      ("Годы постройки:", building.constructionYears.map(\.description)),
      ("Стиль:", building.styles.map(\.title)),
    ]
      .filter { !$0.1.isEmpty }
      .map { getSV(title: $0.0, values: $0.1) }
      .forEach(stackView.addArrangedSubview)
    
    stackView.addArrangedSubview(.init())
    
    goToCityWallsButton.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(goToCityWallsButton)
    
    activate(
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
      galleryViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
      goToCityWallsButton.heightAnchor.constraint(equalToConstant: 50)
    )

  }
  
  func configureButton() {
    goToCityWallsButton.setTitle("Перейти на CityWalls", for: .normal)
    goToCityWallsButton.backgroundColor = .systemBlue
    goToCityWallsButton.layer.cornerRadius = 10
    goToCityWallsButton.addTarget(self, action: #selector(goToCityWalls), for: .touchUpInside)
  }

  func getSV(title: String, values: [String]) -> UIStackView {
    let stackView = UIStackView()
      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
      .set(\.axis, to: .horizontal)
      .set(\.distribution, to: .fillEqually)
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    stackView.addArrangedSubview(titleLabel)
    stackView.alignment = .top
    let valuesStackView = UIStackView()
      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
      .set(\.axis, to: .vertical)
      .set(\.alignment, to: .leading)
    for value in values {
      let valueLabel = UILabel()
      valueLabel.text = value
      valuesStackView.addArrangedSubview(valueLabel)
    }
    valuesStackView.addArrangedSubview(.init())
    stackView.addArrangedSubview(valuesStackView)
    return stackView
  }
  
  @objc func goToCityWalls() {
    UIApplication.shared.open(building.buildingURL)
  }
  
}

extension Building {
  
  var buildingURL: URL { URL(string: "https://www.citywalls.ru/house\(id).html")! }
  
}
