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
  
  @EnvironmentObject var viewModel: BuildingViewModel
  @GestureState var draggingOffset: CGSize = .zero
  
  var body: some View {
    TabView(selection: $viewModel.selectedImageIndex) {
      ForEach(viewModel.images.indices, id: \.self) { index in
        let imageURL = viewModel.images[index]
        AsyncImage(url: imageURL) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(viewModel.scaleEffectForImage(atIndex: index))
        } placeholder: {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
        }
        .scaledToFit()
        .offset(y: viewModel.imageViewerOffset.height)
        .tag(imageURL)
        .gesture(
          MagnificationGesture().onChanged({ value in
            viewModel.imageScale = value
          }).onEnded({ _ in
            withAnimation(.spring()) {
              viewModel.imageScale = 1
            }
          })
          .simultaneously(with: TapGesture(count: 2).onEnded({
            withAnimation {
              viewModel.imageScale = viewModel.imageScale > 1 ? 1 : 4
            }
          }))
        )
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    .overlay(
      Button(action: {
        withAnimation(.default) {
          viewModel.showImageViewer.toggle()
        }
      }, label: {
        Image(systemName: "xmark")
          .foregroundColor(.white)
          .padding(.all, 7)
          .background(Color.white.opacity(0.35))
          .clipShape(Circle())
      })
      .padding(10),
      alignment: .topTrailing
    )
    .gesture(DragGesture().updating($draggingOffset, body: { value, outValue, transaction in
      outValue = value.translation
      viewModel.onChange(value: draggingOffset)
    }).onEnded(viewModel.onEnd(value:)))
  }
  
}

struct ImageView_Previews: PreviewProvider {
  
  static var previews: some View {
    BuildingView(viewModel: .test)
  }
  
}
