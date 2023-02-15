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
  @GestureState var draggingOffset: CGSize = .zero
  
  var body: some View {
    ZStack {
      Color
        .black
        .opacity(buldingViewModel.backgroundOpacity)
        .ignoresSafeArea()
      TabView(selection: $buldingViewModel.selectedImageURL) {
        ForEach(buldingViewModel.images, id: \.self) { imageURL in
          AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
          } placeholder: {
            ProgressView()
          }
          .background(Color.gray)
          .scaledToFit()
          .tag(imageURL)
          .offset(y: buldingViewModel.imageViewerOffset.height)
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
      .overlay(
        Button(action: {
          withAnimation(.default) {
            buldingViewModel.showImageViewer.toggle()
          }
        }, label: {
          Image(systemName: "xmark")
            .foregroundColor(.white)
            .padding()
            .background(Color.white.opacity(0.35))
            .clipShape(Circle())
        })
        .padding(10),
        alignment: .topTrailing
      )
    }
    .gesture(DragGesture().updating($draggingOffset, body: { value, outValue, transaction in
      outValue = value.translation
      buldingViewModel.onChange(value: draggingOffset)
    }).onEnded(buldingViewModel.onEnd(value:)))
  }
  
}

struct ImageView_Previews: PreviewProvider {
  
  static var previews: some View {
    BuildingView(viewModel: .test)
  }
  
}
