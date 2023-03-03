//
//  PageControl.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 22.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SwiftUI

struct PageControl: UIViewRepresentable {
  var numberOfPages: Int
  @Binding var currentPage: Int

  func makeCoordinator() -> Coordinator {
    Coordinator(control: self)
  }

  func makeUIView(context: Context) -> some UIPageControl {
    let control = UIPageControl()
    control.backgroundStyle = .prominent
    control.numberOfPages = numberOfPages
    control.addTarget(context.coordinator,
                      action: #selector(Coordinator.updateCurrentPage(sender:)),
                      for: .valueChanged)
    return control
  }

  func updateUIView(_ uiView: UIViewType, context _: Context) {
    uiView.currentPage = currentPage
  }

  class Coordinator: NSObject {
    var control: PageControl

    init(control: PageControl) {
      self.control = control
    }

    @objc
    func updateCurrentPage(sender: UIPageControl) {
      control.currentPage = sender.currentPage
    }
  }
}
