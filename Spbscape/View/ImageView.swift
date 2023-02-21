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
  
  @EnvironmentObject var buildingViewModel: BuildingViewModel
  @GestureState var draggingOffset: CGSize = .zero
  
  var body: some View {
    TabView(selection: $buildingViewModel.selectedImageURL) {
      ForEach(buildingViewModel.images, id: \.self) { imageURL in
        AsyncImage(url: imageURL) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(buildingViewModel.scaleEffect(for: imageURL))
        } placeholder: {
          ProgressView()
        }
        .background(Color.gray)
        .scaledToFit()
        .offset(y: buildingViewModel.imageViewerOffset.height)
        .gesture(
          MagnificationGesture().onChanged({ value in
            buildingViewModel.imageScale = value
          }).onEnded({ _ in
            withAnimation(.spring()) {
              buildingViewModel.imageScale = 1
            }
          })
          .simultaneously(with: TapGesture(count: 2).onEnded({
            withAnimation {
              buildingViewModel.imageScale = buildingViewModel.imageScale > 1 ? 1 : 4
            }
          }))
        )
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    .overlay(
      Button(action: {
        withAnimation(.default) {
          buildingViewModel.showImageViewer.toggle()
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
    .gesture(DragGesture().updating($draggingOffset, body: { value, outValue, transaction in
      outValue = value.translation
      buildingViewModel.onChange(value: draggingOffset)
    }).onEnded(buildingViewModel.onEnd(value:)))
  }
  
}

struct ImageView_Previews: PreviewProvider {
  
  static var previews: some View {
    BuildingView(viewModel: .test)
  }
  
}
