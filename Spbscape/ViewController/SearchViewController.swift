//
//  SearchViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 05.02.2022.
//  Copyright © 2022 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit
#if targetEnvironment(macCatalyst)
import Combine
#endif

final class SearchViewController: UIViewController {
  
  private let mainStackView: UIStackView
  private let backgroundView: UIVisualEffectView
  let headerViewController: SearchHeaderViewController
  let bodyViewController: UIViewController
  
  private let stackSpacing: CGFloat = 10
  
  #if targetEnvironment(macCatalyst)
  var showFilterSubscriber: AnyCancellable?
  #endif
        
  init(headerViewController: SearchHeaderViewController,
       bodyViewController: UIViewController) {
    self.mainStackView = UIStackView()
    self.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    self.headerViewController = headerViewController
    self.bodyViewController = bodyViewController
    super.init(nibName: .none, bundle: .none)
    addChild(headerViewController)
    headerViewController.didMove(toParent: self)
    addChild(bodyViewController)
    bodyViewController.didMove(toParent: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBackgroundView()
    setupMainStackView()
    setupLayout()
  }

}

private extension SearchViewController {
  
  func setupLayout() {
    let topAnchor: NSLayoutYAxisAnchor
    #if targetEnvironment(macCatalyst)
    topAnchor = view.safeAreaLayoutGuide.topAnchor
    #else
    topAnchor = view.topAnchor
    #endif
    
    view.addSubview(backgroundView)

    activate(
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    )
    backgroundView.contentView.addSubview(mainStackView)
    let mainStackViewInsets = UIEdgeInsets(top: 5,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
    mainStackView.pin(to: backgroundView,
                  insets: mainStackViewInsets)

  
    let headerView = headerViewController.view!
    headerView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.addArrangedSubview(headerView)
    
    let bodyView = bodyViewController.view!
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.addArrangedSubview(bodyView)
  }
  
  func setupMainStackView() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.spacing = stackSpacing
  }
  
  func setupBackgroundView() {
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    if headerViewController.style == .overlay {
      backgroundView.clipsToBounds = true
      backgroundView.layer.cornerRadius = 12
      backgroundView.layer.maskedCorners = [
        .layerMaxXMinYCorner,
        .layerMinXMinYCorner
      ]
    }
  }
  
}

extension SearchViewController: OverlayingView {
  
  var compactHeight: CGFloat {
    headerViewController.compactHeight
  }
  
  func notifyCompact() {
    if headerViewController.searchTextField.isEditing {
      headerViewController.searchTextField.endEditing(true)
    }
  }
  
}
