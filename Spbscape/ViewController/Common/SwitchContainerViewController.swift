//
//  SwitchContainerViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12/12/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

class SwitchContainerViewController: UIViewController {
  var viewControllers: [UIViewController]

  init(viewControllers: [UIViewController]) {
    self.viewControllers = viewControllers
    super.init(nibName: nil, bundle: nil)
    for viewController in viewControllers {
      addChild(viewController)
      viewController.didMove(toParent: self)
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setVisibleViewController(atIndex index: Int) {
    viewControllers
      .map(\.view)
      .enumerated()
      .forEach { viewIndex, view in
        view?.isHidden = viewIndex != index
      }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let stackView = UIStackView(autolayout: ())
    viewControllers.compactMap(\.view).forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview($0)
    }
    view.addSubview(stackView)
    activate(
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )
    setVisibleViewController(atIndex: 0)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if presentedViewController == nil {
      setVisibleViewController(atIndex: 0)
    }
  }
}
