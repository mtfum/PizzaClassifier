//
//  ContentViewModel.swift
//  PizzaClassifier
//
//  Created by Fumiya Yamanaka on 2021/08/21.
//

import UIKit
import Vision

final class ViewModel: ObservableObject {

  @Published var visionRequests: [VNRequest] = []
  @Published var resultText = ""

  @Published var selectedImage: UIImage?
  @Published var isPresentingImagePicker = false
  private(set) var sourceType: ImagePicker.SourceType = .camera

  private let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue

  init() {
    setupVision()
  }

  func choosePhoto() {
    sourceType = .photoLibrary
    isPresentingImagePicker = true
  }

  func takePhoto() {
    sourceType = .camera
    isPresentingImagePicker = true
  }

  func didSelectImage(_ image: UIImage?) {
    selectedImage = image
    isPresentingImagePicker = false

    updateCoreML()
//    loopCoreMLUpdate()
  }

  private func setupVision() {

    // Set up Vision Model
    guard let selectedModel = try? VNCoreMLModel(for: PizzaClassifier(configuration: .init()).model) else {
      fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project from https://developer.apple.com/machine-learning/ . Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
    }

    // Set up Vision-CoreML Request
    let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
    classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
    visionRequests = [classificationRequest]
  }

  private func classificationCompleteHandler(request: VNRequest, error: Error?) {
    if let e = error {
      print("Error: " + e.localizedDescription)
      return
    }
    guard let observations = request.results, observations.count > 2 else {
      print("No results")
      return
    }

    print(observations)

    // Get Classifications
    let classifications = observations[0...1] // top 2 results
      .compactMap({ $0 as? VNClassificationObservation })
      .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
      .joined(separator: "\n")

    DispatchQueue.main.async {
      // Print Classifications
      print(classifications)
      print("--")

      self.resultText = classifications
    }
  }

  private func updateCoreML() {
    guard let uiImage = selectedImage, let ciImage = CIImage(image: uiImage) else { return }

    let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])

    do {
        try imageRequestHandler.perform(self.visionRequests)
    } catch {
        print(error)
    }
  }

  func loopCoreMLUpdate() {
      // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)

      dispatchQueueML.async {
          // 1. Run Update.
          self.updateCoreML()

          // 2. Loop this function.
          self.loopCoreMLUpdate()
      }

  }

}
