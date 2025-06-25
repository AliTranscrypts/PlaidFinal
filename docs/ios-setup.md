# iOS Development Setup Guide

This guide provides detailed instructions for setting up and running the PlaidFinal iOS application.

## Prerequisites

### System Requirements
- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: iOS 14.0+
- **Swift**: 5.9 or later

### Required Tools
```bash
# Check Xcode version
xcodebuild -version

# Check Swift version
swift --version

# Check if Xcode command line tools are installed
xcode-select -p
```

## Initial Setup

### 1. Install Xcode Command Line Tools (if needed)
```bash
xcode-select --install
```

### 2. Clone and Navigate to Project
```bash
git clone https://github.com/yourusername/PlaidFinal.git
cd PlaidFinal
```

### 3. Resolve Swift Package Dependencies
```bash
swift package resolve
```

This will download:
- Plaid iOS SDK (LinkKit)
- Any other Swift package dependencies

## Building the App

### Option 1: Using Terminal (Recommended for CI/CD)

#### List Available Simulators
```bash
xcrun simctl list devices
```

#### Build for Specific Simulator
```bash
# For iPhone 16 Pro
xcodebuild -scheme PlaidFinal \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  build

# For iPhone 15
xcodebuild -scheme PlaidFinal \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  build
```

#### Build for Generic iOS Device
```bash
xcodebuild -scheme PlaidFinal \
  -destination 'generic/platform=iOS' \
  build
```

### Option 2: Using Xcode IDE

1. Open the project:
   ```bash
   open PlaidFinal.xcodeproj
   ```

2. Select your target device from the scheme selector
3. Press `Cmd+B` to build
4. Press `Cmd+R` to run

## Running in Simulator

### 1. Boot Simulator
```bash
# Boot specific simulator
xcrun simctl boot "iPhone 16 Pro"

# Open Simulator app
open -a Simulator
```

### 2. Install the App
```bash
# Find the app bundle
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "PlaidFinal.app" | grep Debug-iphonesimulator | head -1)

# Install to booted simulator
xcrun simctl install booted "$APP_PATH"
```

### 3. Launch the App
```bash
# Launch by bundle ID
xcrun simctl launch booted com.plaidfinal.app

# Launch with console output
xcrun simctl launch --console booted com.plaidfinal.app
```

## Debugging

### View Console Logs
```bash
# Stream all logs from the app
xcrun simctl spawn booted log stream --predicate 'process == "PlaidFinal"'

# Filter for specific log types
xcrun simctl spawn booted log stream --predicate 'process == "PlaidFinal"' | grep -E "(🔵|❌|📤|📥|✅|Error)"
```

### Debug with LLDB
```bash
# Attach debugger to running app
xcrun lldb -n PlaidFinal
```

### View Network Traffic
```bash
# Use Proxyman or Charles Proxy to inspect API calls
# Set proxy in simulator: Settings > Wi-Fi > (i) > Configure Proxy
```

## Configuration

### Update Backend URL
Edit `PlaidFinal/Config.swift`:
```swift
enum Config {
    static let backendURL = "https://your-backend-url.vercel.app"
}
```

### Change Bundle Identifier
1. Open `PlaidFinal.xcodeproj`
2. Select the project in navigator
3. Select "PlaidFinal" target
4. Change "Bundle Identifier" in Identity section

### Code Signing (for Device Testing)
1. Select your Apple Developer team
2. Enable "Automatically manage signing"
3. Xcode will create provisioning profiles

## Testing on Physical Device

### 1. Connect Device
- Connect iPhone/iPad via USB
- Trust the computer on device

### 2. Build and Run
```bash
# List connected devices
xcrun devicectl list devices

# Build for connected device
xcodebuild -scheme PlaidFinal \
  -destination 'platform=iOS,name=Your iPhone Name' \
  build
```

### 3. Install via Xcode
- Select your device in Xcode
- Press `Cmd+R`

## Troubleshooting

### Common Issues

#### "No such module 'LinkKit'"
```bash
# Clean and resolve packages
rm -rf .build/
rm -rf ~/Library/Developer/Xcode/DerivedData/PlaidFinal-*
swift package resolve
```

#### "Failed to launch simulator"
```bash
# Reset simulator
xcrun simctl erase all
killall Simulator
```

#### Build Failures
```bash
# Clean build folder
xcodebuild clean -scheme PlaidFinal

# Reset package cache
rm -rf ~/Library/Caches/org.swift.swiftpm
```

#### Signing Issues
- Ensure you have a valid Apple Developer account
- Check keychain for expired certificates
- Regenerate provisioning profiles if needed

## Performance Optimization

### Build Settings
- Use "Release" configuration for performance testing
- Enable "Whole Module Optimization"
- Set "Swift Optimization Level" to `-O`

### Instruments
```bash
# Launch Instruments
instruments -t "Time Profiler" PlaidFinal.app
```

## Continuous Integration

### Sample Build Script
```bash
#!/bin/bash
set -e

# Clean
xcodebuild clean -scheme PlaidFinal

# Build
xcodebuild build \
  -scheme PlaidFinal \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Release \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# Test (if tests exist)
xcodebuild test \
  -scheme PlaidFinal \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Plaid iOS SDK Documentation](https://plaid.com/docs/link/ios/) 