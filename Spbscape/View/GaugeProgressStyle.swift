//
//  GaugeProgressStyle.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 22.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
  var strokeColor = ColorScheme.primaryColor
  var strokeWidth = 25.0
  
  func makeBody(configuration: Configuration) -> some View {
    let fractionCompleted = configuration.fractionCompleted ?? 0
    
    return ZStack {
      Circle()
        .trim(from: 0, to: fractionCompleted)
        .stroke(Color(uiColor: ColorScheme.primaryColor), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
        .rotationEffect(.degrees(-90))
    }
  }
}
