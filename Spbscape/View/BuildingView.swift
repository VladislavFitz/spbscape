//
//  BuildingView.swift
//  Spbscape
//
//  Created by Vladislav Fitc on 12.02.2023.
//  Copyright © 2023 Vladislav Fitc. All rights reserved.
//

import Foundation
import SwiftUI

struct BuildingView: View {
  @StateObject var viewModel: BuildingViewModel

  @Environment(\.openURL) var openURL

  var body: some View {
    VStack {
      Text(viewModel.title)
        .font(.system(size: 23, weight: .bold))
        .padding(.horizontal, 10)
        .padding(.top, 15)
      TabView(selection: $viewModel.selectedImageIndex) {
        ForEach(viewModel.images.indices, id: \.self) { index in
          let image = viewModel.images[index]
          Button(action: {
            withAnimation(.easeInOut) {
              viewModel.selectedImageIndex = index
              viewModel.showImageViewer.toggle()
            }
          }, label: {
            AsyncImage(url: image) { image in
              image
                .resizable()
            } placeholder: {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            }
            .scaledToFit()
            .tag(index)
          })
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      PageControl(numberOfPages: viewModel.images.count,
                  currentPage: $viewModel.selectedImageIndex)
      ScrollView {
        VStack {
          ForEach(viewModel.content(), id: \.key) { key, value in
            Text(LocalizedStringKey(key))
              .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.system(size: 16, weight: .semibold))
              .padding(.bottom, 10)
          }
        }.padding(.horizontal, 10)
      }
      Button {
        openURL(URL(string: "https://www.citywalls.ru/house\(viewModel.citywallsID).html")!)
      } label: {
        Text(LocalizedStringKey("go-to-citywalls"))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 7)
      }
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 10)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .fullScreenCover(isPresented: $viewModel.showImageViewer) {
      ImageView()
        .environmentObject(viewModel)
    }
  }
}

struct BuldingView_Previews: PreviewProvider {
  static var previews: some View {
    BuildingView(viewModel: .test)
  }
}

extension BuildingViewModel {
  static let test = BuildingViewModel(
    title: "Доходный дом М. М. Горбова",
    images: [
      URL(string: "https://p2.citywalls.ru/photo_4-4518.jpg")!,
      URL(string: "https://p2.citywalls.ru/photo_80-82266.jpg")!,
      URL(string: "https://p3.citywalls.ru/photo_259-265387.jpg")!
    ],
    address: "Каменноостровский пр., 20, Мира ул., 10, Австрийская пл., 3",
    architects: "Шауб В. В.",
    constructionYears: "1902-1903",
    style: "Модерн",
    citywallsID: "836"
  )
}
