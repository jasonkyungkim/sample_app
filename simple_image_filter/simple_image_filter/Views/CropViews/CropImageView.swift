//
//  ContentView.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct CropImageView: View {
    // Environment and State properties
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var croppedImage: UIImage?
    @State private var sticker: UIImage?
    @State private var spoilerViewOpacity = 0.0
    @State private var stickerScale = 1.0
    @State private var isLoading = false
    @State private var previewOn = false
    
    // Queue for image processing tasks
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")
    private let animation: Animation = .easeInOut(duration: 1)
    
    var body: some View {
        NavigationStack {
            VStack {
                if let imageToShow = sticker ?? croppedImage {
                    Spacer()
                    
                    ZStack {
                        // Display the chosen or modified image
                        Image(uiImage: imageToShow)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350)
                            .clipShape(Circle())
                            .transition(.opacity.animation(animation))
                        
                        // Overlay bubble effect with animation
                        Image("bubble_mid")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(previewOn ? 1 : 0)
                            .frame(width: 372)
                            .transition(.opacity.animation(animation))
                    }
                    .shadow(color: .bindigo.opacity(previewOn ? 1 : 0), radius: 10)
                    Button(action: {
                        withAnimation(animation) {
                            createSticker()
                            previewOn.toggle()
                        }
                    }) {
                        VStack {
                            Text(previewOn ? "Original" : "Apply Filter")
                                .font(.headline)
                                .bold()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThickMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.animation(animation))
                    
                    Spacer()
                    
                    LongPressButton(titleText: "Long press to choose another picture", applied: $showPicker)
                        .padding(.bottom, 100)
                } else {
                    // Button to start by choosing an image
                    LongPressButton(titleText: "Long press to get started", applied: $showPicker)
                        .padding(.bottom, 100)
                }
            }
            .navigationTitle("Apply Cool Filter!")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Spinner()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .cropImagePicker(show: $showPicker, croppedImage: $croppedImage)
            .onChange(of: croppedImage) { _, _ in
                withAnimation(animation) {
                    sticker = nil  // Reset sticker when a new image is selected
                    previewOn = false
                }
            }
        }
    }
    
    // MARK: - Create Sticker
    private func createSticker() {
        if sticker != nil {
            // Revert to original image if sticker exists
            withAnimation(.easeInOut(duration: 1)) {
                sticker = nil
            }
            return
        }
        
        guard let croppedImage = croppedImage,
              let inputImage = CIImage(image: croppedImage) else {
            print("Failed to create CIImage")
            return
        }
        
        isLoading = true
        processingQueue.async {
            guard let maskImage = self.subjectMaskImage(from: inputImage) else {
                print("Failed to create mask image")
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            let outputImage = self.apply(maskImage: maskImage, to: inputImage, backgroundColor: .bpink)
            let image = self.render(ciImage: outputImage)
            DispatchQueue.main.async {
                self.isLoading = false
                withAnimation(.easeInOut(duration: 1)) { self.sticker = image }
            }
        }
    }
    
    // MARK: - Generate Subject Mask
    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Apply Mask
    private func apply(maskImage: CIImage, to inputImage: CIImage, backgroundColor: UIColor) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = inputImage
        filter.maskImage = maskImage
        
        let colorImage = CIImage(color: CIColor(color: backgroundColor))
            .cropped(to: inputImage.extent)
        
        filter.backgroundImage = colorImage
        return filter.outputImage!
    }
    
    // MARK: - Render Final Image
    private func render(ciImage: CIImage) -> UIImage {
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
}
