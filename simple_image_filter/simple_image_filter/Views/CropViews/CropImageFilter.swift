//
//  CropImageFilter.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//


import SwiftUI
import PhotosUI

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        CustomImagePicker(show: show, croppedImage: croppedImage) {
            self
        }
    }
    
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Custom Image Picker
struct CustomImagePicker<Content: View>: View {
    var content: Content
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?

    @State private var photosItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var showCropView: Bool = false

    // Initialize the custom image picker
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }
    
    var body: some View {
        if showCropView {
            if let selectedImage = selectedImage {
                CropView(image: selectedImage, showCropView: $showCropView) { croppedImage, status in
                    if let croppedImage = croppedImage {
                        self.croppedImage = croppedImage
                        withAnimation(.easeInOut(duration: 1)) {
                            self.showCropView = false
                        }
                    }
                }
                .transition(.opacity)
            } else {
                Text("No image selected.")
                    .onAppear {
                        withAnimation {
                            showCropView = false
                        }
                    }
            }
        } else {
            content
                .photosPicker(isPresented: $show, selection: $photosItem, matching: .images)
                .onChange(of: photosItem) { _, newValue in
                    guard let newValue = newValue else { return }
                    loadTransferable(from: newValue)
                }
                .onAppear {
                    selectedImage = nil
                }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            if let imageData = try? await imageSelection.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                await MainActor.run {
                    self.selectedImage = image
                    withAnimation {
                        self.showCropView = true
                    }
                }
            }
        }
    }
}

// MARK: - Crop View
struct CropView: View {
    var image: UIImage?
    @Binding var showCropView: Bool
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var onCrop: (UIImage?, Bool) -> ()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ImageView()
                Text("""
                     Center your face in the circle for best results.
                     Ensure your face is fully visible.
                     """)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                MyButton(title: "Confirm Crop", action: confirmCrop)
                    .padding(.horizontal)
                    .padding(.bottom, 100)
            }
            .navigationTitle("Crop Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            showCropView = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Confirm Crop Action
    private func confirmCrop() {
        let renderer = ImageRenderer(content: ImageView(true))
        renderer.proposedSize = .init(width: 350, height: 350)
        renderer.scale = 10.0
        
        if let image = renderer.uiImage {
            withAnimation(.bouncy) {
                onCrop(image, true)
            }
        } else {
            onCrop(nil, false)
        }
    }
    
    // MARK: - Image View
    @ViewBuilder
    func ImageView(_ hideGrids: Bool = false) -> some View {
        let cropSize = CGSize(width: 350, height: 350)
        GeometryReader { geometry in
            let size = geometry.size
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(content: {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            
                            Color.clear
                                .onChange(of: isInteracting) { _, newValue in
                                    withAnimation(.bouncy()) {
                                        handleImageInteraction(rect: rect, size: size, isInteracting: newValue)
                                    }
                                }
                        }
                    })
                    .frame(size)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .overlay(content: {
            if !hideGrids && isInteracting {
                Grids()
            }
        })
        .coordinateSpace(name: "CROPVIEW")
        .gesture(dragGesture)
        .gesture(magnificationGesture)
        .frame(cropSize)
        .clipShape(
            .rect(
                topLeadingRadius: cropSize.height / 2,
                bottomLeadingRadius: cropSize.height / 2,
                bottomTrailingRadius: cropSize.height / 2,
                topTrailingRadius: cropSize.height / 2
            )
        )
    }
    
    // MARK: - Handle Image Interaction
    private func handleImageInteraction(rect: CGRect, size: CGSize, isInteracting: Bool) {
        if rect.minX > 0 {
            offset.width -= rect.minX
            haptics(.medium)
        }
        
        if rect.minY > 0 {
            offset.height -= rect.minY
            haptics(.medium)
        }
        
        if rect.maxX < size.width {
            offset.width = rect.minX - offset.width
            haptics(.medium)
        }
        
        if rect.maxY < size.height {
            offset.height = rect.minY - offset.height
            haptics(.medium)
        }
        
        if !isInteracting {
            lastStoredOffset = offset
        }
    }
    
    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isInteracting) { _, out, _ in
                out = true
            }
            .onChanged { value in
                let translation = value.translation
                offset = CGSize(width: translation.width + lastStoredOffset.width,
                                height: translation.height + lastStoredOffset.height)
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($isInteracting) { _, out, _ in
                out = true
            }
            .onChanged { value in
                let updatedScale = value + lastScale
                scale = max(updatedScale, 1) // Ensure scale is at least 1
            }
            .onEnded { value in
                withAnimation(.spring) {
                    if scale < 1 {
                        scale = 1
                        lastScale = 0
                    } else {
                        lastScale = scale - 1
                    }
                }
            }
    }
    
    // MARK: - Grids Overlay
    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            HStack {
                ForEach(1...3, id: \.self) { _ in
                    Rectangle()
                        .fill(.white)
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            VStack {
                ForEach(1...3, id: \.self) { _ in
                    Rectangle()
                        .fill(.white)
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}
