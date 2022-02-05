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

final class BuildingViewController: UIViewController {
  
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
    title = building.titles.joined(separator: ", ")
    titleLabel.text = building.titles.joined(separator: ", ")
    titleLabel.font = .systemFont(ofSize: 24, weight: .heavy)
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
    stackView.spacing = 6
    stackView.distribution = .fill
    view.addSubview(stackView)
    
    galleryViewController.pageControl.hidesForSinglePage = true
    galleryViewController.pageControl.pageIndicatorTintColor = .lightGray
    galleryViewController.pageControl.currentPageIndicatorTintColor = .black

    galleryViewController.pageControl.layer.masksToBounds = true
    galleryViewController.pageControl.translatesAutoresizingMaskIntoConstraints = false
    
    let imageStackView = UIStackView()
    imageStackView.axis = .vertical
    imageStackView.translatesAutoresizingMaskIntoConstraints = false
    imageStackView.addArrangedSubview(galleryViewController.view)
    imageStackView.addArrangedSubview(galleryViewController.pageControl)
    stackView.addArrangedSubview(imageStackView)

    [
      ("Адрес", building.addresses.map(\.description)),
      ("Архитекторы", building.architects.map(\.title)),
      ("Годы постройки", building.constructionYears.map(\.description)),
      ("Стиль", building.styles.map(\.title)),
    ]
      .filter { !$0.1.isEmpty }
      .map { getSV(title: $0.0, values: $0.1) }
      .forEach(stackView.addArrangedSubview)
    
    stackView.addArrangedSubview(.init())
    
    goToCityWallsButton.translatesAutoresizingMaskIntoConstraints = false
    let placeholder = UIView()
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(placeholder)
    stackView.addArrangedSubview(goToCityWallsButton)
    
    let stackViewContainer = UIView()
    stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addSubview(stackView)
    activate(
      stackView.topAnchor.constraint(equalTo: stackViewContainer.safeAreaLayoutGuide.topAnchor, constant: 7),
      stackView.leadingAnchor.constraint(equalTo: stackViewContainer.leadingAnchor, constant: 7),
      stackView.trailingAnchor.constraint(equalTo: stackViewContainer.trailingAnchor, constant: -7),
      stackView.bottomAnchor.constraint(equalTo: stackViewContainer.bottomAnchor, constant: -7)
    )
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stackViewContainer)
    stackViewContainer.pin(to: scrollView)
    
    view.addSubview(scrollView)
    
    activate(
      stackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      stackViewContainer.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      galleryViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
      goToCityWallsButton.heightAnchor.constraint(equalToConstant: 44)
    )

  }
  
  func configureButton() {
    goToCityWallsButton.setTitle("Перейти на CityWalls", for: .normal)
    goToCityWallsButton.backgroundColor = ColorScheme.tintColor
    goToCityWallsButton.layer.cornerRadius = 10
    goToCityWallsButton.addTarget(self, action: #selector(goToCityWalls), for: .touchUpInside)
  }

  func getSV(title: String, values: [String]) -> UIStackView {
    let stackView = UIStackView()
      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
      .set(\.axis, to: .vertical)
      .set(\.distribution, to: .fillEqually)
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 12, weight: .light)
    stackView.addArrangedSubview(titleLabel)
    stackView.alignment = .top
    let valueLabel = UILabel()
    valueLabel.numberOfLines = 0
    valueLabel.text = values.joined(separator: ", ")
    valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    stackView.addArrangedSubview(valueLabel)
//    let valuesStackView = UIStackView()
//      .set(\.translatesAutoresizingMaskIntoConstraints, to: false)
//      .set(\.axis, to: .vertical)
//      .set(\.alignment, to: .leading)
//    for value in values {
//      let valueLabel = UILabel()
//      valueLabel.text = value
//      valuesStackView.addArrangedSubview(valueLabel)
//    }
//    valuesStackView.addArrangedSubview(.init())
//    stackView.addArrangedSubview(valuesStackView)
    return stackView
  }
  
  @objc func goToCityWalls() {
    UIApplication.shared.open(building.buildingURL)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  
}

extension Building {
  
  var buildingURL: URL { URL(string: "https://www.citywalls.ru/house\(id).html")! }
  
}
