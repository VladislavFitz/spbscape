//
//  ImageView.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 14.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageView: View {
  
  @EnvironmentObject var buldingViewModel: BuildingViewModel
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      TabView(selection: $buldingViewModel.selectedImageURL) {
        ForEach(buldingViewModel.images, id: \.self) { image in
          AsyncImage(url: image) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
          } placeholder: {
            ProgressView()
          }
          .background(Color.gray)
          .scaledToFit()
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
  }
  
}

struct ImageView_Previews: PreviewProvider {
  
  static var previews: some View {
    ImageView()
      .environmentObject(BuildingViewModel.test)
  }
  
}
