# Background Remover & Filter App

## Overview
This app serves as a compilation of features developed for my side project, created specifically for demonstration purposes.

- **SwiftUI Image Cropper and Filter**: A custom image picker and processing solution for iOS that combines sophisticated cropping capabilities with special visual effects.

## Features
- Custom circular image cropping with interactive gestures
- Zoom and pan functionality with grid overlay
- Subject isolation using Vision framework
- Background color effects with smooth transitions
- Preview mode to compare original and filtered images
- Haptic feedback for better user experience

## Components
- `CustomImagePicker`: Handles image selection and presents the crop interface
- `CropView`: Provides interactive cropping functionality
- `CropImageView`: Main view that combines picking, cropping, and filtering capabilities

## Technical Details
- Built with SwiftUI and Vision framework
- Uses `PhotosPicker` for image selection
- Implements custom gesture handling for image manipulation
- Processes images asynchronously on a dedicated dispatch queue
- Supports dynamic UI updates with smooth animations

## Extra Features
- **Bouncy Button Interface**: This component offers a visually rich, interactive button with a long-press gesture that triggers an animated progress overlay. As the user holds the button, a circular progress indicator advances, applying a specified action when progress reaches a set threshold. The button includes animations for scaling, shadow, and opacity, providing real-time feedback on the press status. Customizable icons and images are layered within the button to give visual cues during interaction, enhancing engagement and ease of use for actions requiring intentional holding.
- **Scrollable Date Selector Sheet**: This component allows users to select a date from a horizontal scrollable sheet that displays the next 14 days. The currently selected date dynamically appears in a button on the main screen, and when opening the sheet, the date is auto-centered for convenience. A visual shadow effect highlights the selected date, enhancing user experience by visually linking the main view and the date picker.
- **Animated Customizable Tab Bar**: This tab bar component features a dynamic, customizable UI with animated transitions and a retractable menu. When users select a tab, a matchedGeometryEffect smoothly highlights the active tab, while icons and text adjust in style based on selection. The retractable menu offers smooth expand/collapse animations, controlled by a toggle button with an animated chevron icon.
