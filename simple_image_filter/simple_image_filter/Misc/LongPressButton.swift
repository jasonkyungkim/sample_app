//
//  LongPressButton.swift
//  simple_image_filter
//
//  Created by Chongkyung Kim on 10/29/24.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let diameterRatio: Double = 0.225
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [.bgreen, .bindigo, .bpink]),
                        center: .trailing,
                        startRadius: 0,
                        endRadius: 315 * 0.35
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 503.597643045 * diameterRatio, height: 503.597643045 * diameterRatio)
                .rotationEffect(.degrees(-90))
                .animation(.bouncy(duration: 7.5), value: progress)
        }
    }
}

struct LongPressButton: View {
    // MARK: - Properties
    @Namespace private var animation
    let titleText: String
    @Binding var applied: Bool

    
    // Configuration Constants
    private let diameterRatio: Double = 0.225
    private let bubbleScaleFactor: CGFloat = 550 * 0.35
    private let bubbleRadius: CGFloat = 0.401775328098079
    private let progressMaxValue = 1000.0
    
    // States
    @State private var progress: Double = 0.0
    @State private var progressTimer: Timer?
    @State private var isDetectingLongPress = false
    @State private var completedLongPress = false

    // MARK: - Body
    var body: some View {
        VStack {
            instructionText
            interactiveCircle
        }
    }
    
    // MARK: - Views
    private var instructionText: some View {
        Text(titleText)
            .foregroundStyle(.secondary)
            .opacity(isDetectingLongPress ? 0 : 0.5)
            .animation(.easeIn, value: isDetectingLongPress)
    }
    
    private var interactiveCircle: some View {
        ZStack {
            bubbleView
            Circle()
                .foregroundStyle(.clear)
                .frame(width: 503.597643045 * diameterRatio)
            
            if isDetectingLongPress {
                longPressProgressOverlay
            }
        }
    }

    private var bubbleView: some View {
        Image("bubble")
            .resizable()
            .scaledToFit()
            .frame(width: bubbleRadius * bubbleScaleFactor * 1.1)
            .overlay(Image(systemName: "photo.on.rectangle.angled").bold().foregroundStyle(.white))
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
                completedLongPress = true
            } onPressingChanged: { inProgress in
                handleLongPressChange(inProgress)
            }
            .scaleEffect(isDetectingLongPress ? 1.15 : 0.95)
            .shadow(color: .bindigo, radius: isDetectingLongPress ? 10 : 0)
            .opacity(isDetectingLongPress ? 1 : 0.45)
            .animation(.easeInOut, value: isDetectingLongPress)
            .overlay(venueImageOverlay)
            .matchedGeometryEffect(id: "bubble", in: animation)
    }
    
    private var venueImageOverlay: some View {
        Image("icecream")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 95)
            .shadow(radius: 5, y: 5)
            .offset(y: 45)
            .opacity(isDetectingLongPress ? 0 : 1)
            .animation(.easeInOut, value: isDetectingLongPress)
    }
    
    private var longPressProgressOverlay: some View {
        ZStack {
            CircularProgressView(progress: progress)
                .opacity(applied ? 0 : 1)
                .animation(.easeOut, value: applied)
            
            Circle()
                .stroke(.gray.opacity(0.15), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 503.597643045 * diameterRatio)
                .rotationEffect(.degrees(-90))
                .opacity(applied ? 0 : 1)
                .animation(.easeOut, value: applied)
                .animation(.bouncy(duration: 7.5), value: progress)
        }
    }
    
    // MARK: - Long Press Handlers
    private func handleLongPressChange(_ inProgress: Bool) {
        isDetectingLongPress = inProgress
        inProgress ? startProgressTimer() : stopProgressTimer()
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateProgress()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progress = 0
    }
    
    private func updateProgress() {
        if progress < progressMaxValue {
            progress += 1
        }
        if progress > 10 {
            applied = true
            stopProgressTimer()
        }
    }
}
