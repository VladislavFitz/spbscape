//
//  FilterResultViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 12/12/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class ContainerViewController: UIViewController {
  
  var viewControllers: [UIViewController]
  
  init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init(nibName: nil, bundle: nil)
    for viewController in viewControllers {
      addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setVisibleViewController(atIndex index: Int) {
    guard index < viewControllers.count else { return }
    viewControllers
      .map(\.view)
      .enumerated()
      .forEach { viewIndex, view in
        view?.isHidden = viewIndex != index
      }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    viewControllers.compactMap(\.view).forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview($0)
    }
    view.addSubview(stackView)
    activate(
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    setVisibleViewController(atIndex: 0)
  }
  
}
