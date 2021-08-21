//
//  ContentView.swift
//  PizzaClassifier
//
//  Created by Fumiya Yamanaka on 2021/08/21.
//

import SwiftUI
import Vision

struct ContentView: View {

  @StateObject private var viewModel = ViewModel()

  var body: some View {
    VStack(spacing: 32) {
      imageView(for: viewModel.selectedImage)
      Text(viewModel.resultText)
      Spacer()
      controlBar()
    }
    .fullScreenCover(isPresented: $viewModel.isPresentingImagePicker, content: {
      ImagePicker(sourceType: viewModel.sourceType, completionHandler: viewModel.didSelectImage)
    })
  }

  @ViewBuilder
  private func imageView(for image: UIImage?) -> some View {
    if let image = image {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
    } else {
      Text("Select Image")
    }
  }

  private func controlBar() -> some View {
    HStack(spacing: 32) {
      Button(action: viewModel.choosePhoto, label: {
        Text("Choose from library")
      })
      Button(action: viewModel.takePhoto, label: {
        Text("Take a Photo")
      })
    }.padding()
  }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
