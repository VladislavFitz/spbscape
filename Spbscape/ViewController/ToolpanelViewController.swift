//
//  ToolpanelViewController.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Combine
import Foundation
import UIKit

class ToolpanelViewController: UIViewController {
  let stackView: UIStackView
  let hitsCountLabel: UILabel
  let filtersButton: UIButton
  var didTapFiltersButton: ((UIButton) -> Void)?

  private var filtersStateSubscriber: AnyCancellable?
  private var resultsCountSubscriber: AnyCancellable?

  private let filtersStateViewModel: FiltersStateViewModel
  private let resultsCountViewModel: ResultsCountViewModel

  init(filtersStateViewModel: FiltersStateViewModel, resultsCountViewModel: ResultsCountViewModel) {
    self.filtersStateViewModel = filtersStateViewModel
    self.resultsCountViewModel = resultsCountViewModel
    stackView = UIStackView(autolayout: ())
    stackView.axis = .horizontal
    stackView.alignment = .center
    hitsCountLabel = UILabel(autolayout: ())
    hitsCountLabel.textColor = ColorScheme.primaryColor
    hitsCountLabel.textAlignment = .center
    hitsCountLabel.text = resultsCountViewModel.resultsCountTitle

    filtersButton = UIButton()
    filtersButton.contentVerticalAlignment = .fill
    filtersButton.contentHorizontalAlignment = .fill

    super.init(nibName: nil,
               bundle: nil)
    filtersButton.addTarget(self,
                            action: #selector(_didTapFiltersButton),
                            for: .touchUpInside)
    filtersStateSubscriber = filtersStateViewModel
      .$filtersButtonImage
      .receive(on: DispatchQueue.main)
      .sink { [weak filtersButton] image in
        filtersButton?.setImage(image, for: .normal)
      }
    resultsCountSubscriber = resultsCountViewModel
      .$resultsCountTitle
      .receive(on: DispatchQueue.main)
      .assign(to: \.text, on: hitsCountLabel)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    backgroundView.layer.cornerRadius = 12
    backgroundView.layer.masksToBounds = true
    view = backgroundView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    (view as? UIVisualEffectView)?.contentView.addSubview(stackView)
    let stackViewInsets = UIEdgeInsets(top: 8,
                                       left: 15,
                                       bottom: -8,
                                       right: -15)
    stackView.pin(to: view,
                  insets: stackViewInsets)
    stackView.addArrangedSubview(hitsCountLabel)
    stackView.addArrangedSubview(filtersButton)
    NSLayoutConstraint.activate([
      filtersButton.widthAnchor.constraint(equalToConstant: 28),
      filtersButton.heightAnchor.constraint(equalToConstant: 28)
    ])
  }

  @objc private func _didTapFiltersButton(_ filterButton: UIButton) {
    didTapFiltersButton?(filterButton)
  }
}
