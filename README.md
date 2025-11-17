# Step Tracking Live Activities

A real-time step tracking iOS app that leverages **Live Activities** and **Dynamic Island** to display your step count, distance, and progress directly on your Lock Screen and Dynamic Island.

## Features

### 🏃‍♂️ Real-Time Step Tracking
- Track steps using CoreMotion's CMPedometer
- Monitor distance traveled in meters/kilometers
- Count floors ascended and descended
- Elapsed time tracking with timer

### 📱 Live Activities Integration
- **Lock Screen**: Large, easy-to-read display with progress bar
- **Dynamic Island**: Compact circular progress indicator with time
- **Frequent Updates**: Updates up to 1Hz on Lock Screen (iOS 16.2+)
- Automatic goal completion detection

### 🎯 Goal Setting
- Customizable step goals (1,000 - 50,000 steps)
- Visual progress tracking with percentage indicator
- Progress bar showing completion status

### ⏯️ Tracking Controls
- Start/Stop tracking
- Pause/Resume functionality
- Automatic stop when goal is reached

## Screenshots

### Lock Screen
- Status badge (In Progress/Paused)
- Large step count display
- Real-time timer
- Progress percentage and bar

### Dynamic Island
- **Compact**: Circular progress ring + timer
- **Expanded**: Full stats with step count and time
- **Minimal**: Progress indicator only

## Requirements

- iOS 16.2 or later (for frequent updates)
- iOS 16.1 or later (for Live Activities)
- Physical device (Live Activities don't work in Simulator)
- Motion & Fitness permission

## Installation

1. Clone the repository:
```bash
git clone https://github.com/321mask/Live-Activities.git
cd Live-Activities
```

2. Open the project in Xcode 15 or later:
```bash
open Live Activities.xcodeproj
```

3. Configure your development team:
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your team

4. Enable required capabilities:
   - **App Groups**: For sharing data between app and extension
   - **Live Activities**: Automatically enabled

5. Build and run on a physical device

## Project Structure

```
Live Activities/
├── LiveActivities/              # Main app
│   ├── ContentView.swift        # Main UI
│   ├── StepTracker.swift        # Step tracking logic
│   └── Info.plist              # App configuration
│
├── StepLiveActivityExtension/   # Live Activity extension
│   ├── StepLiveActivity.swift  # Live Activity UI
│   └── Info.plist              # Extension configuration
│
└── Shared/
    └── StepActivityAttributes.swift  # Shared data model
```

## Configuration

### Info.plist Settings

**Main App (Info.plist)**:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
<key>NSMotionUsageDescription</key>
<string>We need access to your motion data to track your steps.</string>
```

**Extension (Info.plist)**:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

### App Groups

Create an App Group to share data between the app and extension:
1. Go to Signing & Capabilities
2. Add "App Groups" capability
3. Create group: `group.com.yourcompany.LiveActivities`
4. Apply to both main app and extension targets

## Usage

### Starting a Tracking Session

```swift
let tracker = StepTracker()
tracker.startTracking(goalSteps: goalSteps)
```

### Pausing/Resuming

```swift
tracker.pauseTracking()
tracker.resumeTracking()
```

### Stopping Tracking

```swift
tracker.stopTracking()
```

### Observing State Changes

The `StepTracker` class is `@Observable`, so you can use it directly in SwiftUI:

```swift
struct ContentView: View {
    @State private var tracker = StepTracker()
    
    var body: some View {
        Text("\(tracker.steps) steps")
        Text("\(tracker.distance) meters")
    }
}
```

## Key Components

### StepTracker
Main tracking logic that:
- Manages CMPedometer updates
- Updates Live Activity every second
- Handles pause/resume state
- Auto-stops when goal is reached

### StepActivityAttributes
Data model for Live Activity:
```swift
struct StepActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var isPaused: Bool
        var steps: Int
        var distance: Double
        var floorsAscended: Int
        var floorsDescended: Int
    }
    
    var goalSteps: Int
}
```

### StepLiveActivity
UI for Lock Screen and Dynamic Island with:
- Lock Screen: Full stats display
- Dynamic Island: Compact progress indicator
- Customizable layouts for different contexts

## Frequent Updates

This app uses **Frequent Updates** to achieve ~1Hz update rate on the Lock Screen:

1. Enabled via `NSSupportsLiveActivitiesFrequentUpdates` in Info.plist
2. Timer updates every second
3. Only works on Lock Screen (Dynamic Island stays at ~4 updates/min)
4. Automatically throttled by iOS to save battery

## Troubleshooting

### Live Activity Not Showing
- Ensure you're running on a physical device
- Check that Live Activities are enabled in Settings
- Verify Info.plist has `NSSupportsLiveActivities = true`

### Updates Not Frequent Enough
- Confirm `NSSupportsLiveActivitiesFrequentUpdates = true`
- Lock the device to see Lock Screen updates
- Dynamic Island updates remain at normal rate

### Permission Issues
- Check Motion & Fitness permission in Settings
- Add proper `NSMotionUsageDescription` in Info.plist

### Build Errors
- Clean build folder (Cmd + Shift + K)
- Delete DerivedData
- Verify all targets have correct Info.plist configuration
- Check target membership for shared files

## Performance

- **Battery Impact**: Moderate (uses CoreMotion + frequent updates)
- **Update Rate**: 
  - Lock Screen: ~1Hz with frequent updates enabled
  - Dynamic Island: ~4 updates per minute
- **Memory Usage**: Low (~20-30MB)

## Privacy

- Step data is only stored locally during active tracking session
- No data is sent to external servers
- Motion permission is required and requested on first use
- All tracking stops when the session ends

## Future Enhancements

- [ ] Historical tracking data persistence
- [ ] Weekly/monthly statistics
- [ ] Achievement system
- [ ] Custom themes for Live Activity
- [ ] Apple Watch companion app
- [ ] HealthKit integration for step history
- [ ] Calorie estimation
- [ ] Social sharing features

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Apple's [ActivityKit documentation](https://developer.apple.com/documentation/activitykit)
- SF Symbols for icons
- CoreMotion framework for step tracking

---

Made with ❤️ using SwiftUI and ActivityKit
