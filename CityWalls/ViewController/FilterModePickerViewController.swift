//
//  FilterModePickerViewController.swift
//  CityWalls
//
//  Created by Vladislav Fitc on 17/10/2020.
//  Copyright © 2020 Vladislav Fitc. All rights reserved.
//

import Foundation
import UIKit

enum FilterMode: CaseIterable {
  case allBuildings
  case architect
  case street
  case style
}

class FilterModePickerViewController: UIViewController {
  
  var buttons: [UIButton]
  var didSelect: ((FilterMode) -> Void)?
  
  init() {
    buttons = []
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    buttons = FilterMode.allCases.map { mode in
      let button = UIButton()
      button.setTitleColor(.black, for: .normal)
      button.setTitleColor(.gray, for: .focused)
      button.setTitleColor(.gray, for: .selected)
      button.setTitle(title(for: mode), for: .normal)
      button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
      return button
    }
    setupLayout()
  }
  
  @objc func didTapButton(_ button: UIButton) {
    guard let buttonIndex = buttons.firstIndex(of: button) else { return }
    let tappedMode = FilterMode.allCases[buttonIndex]
    didSelect?(tappedMode)
  }
  
  private func title(for mode: FilterMode) -> String {
    switch mode {
    case .allBuildings:
      return "Все здания"
    case .architect:
      return "Архитектор"
    case .street:
      return "Улица"
    case .style:
      return "Стиль"
    }
  }
  
  func setupLayout() {
    let stackView = UIStackView()
    stackView.spacing = 10
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    stackView.pin(to: view.safeAreaLayoutGuide, insets: .init(top: 10, left: 10, bottom: -10, right: -10))
    buttons
      .map(\.heightAnchor)
      .map { $0.constraint(equalToConstant: 50) }
      .forEach { $0.isActive = true }
    buttons.forEach { button in
      button.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(button)
    }
    stackView.addArrangedSubview(.placeholder)
  }
  
}
