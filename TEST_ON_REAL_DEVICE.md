# Testing on Real iOS Device

## Prerequisites

1. **Connect your iPhone via USB cable**
2. **Unlock your iPhone** and trust the computer if prompted
3. **Enable Developer Mode** on your iPhone:
   - Settings → Privacy & Security → Developer Mode → Enable
   - Restart your iPhone if prompted

## Method 1: Using Flutter CLI (Recommended)

### Step 1: Check Connected Devices
```bash
flutter devices
```

You should see your iPhone listed, for example:
```
Asad's iPhone (mobile) • 00008120-001235892E93C01E • ios • iOS 26.0
```

### Step 2: Build and Install
```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub
flutter run -d 00008120-001235892E93C01E
```

Replace `00008120-001235892E93C01E` with your actual device ID.

### Step 3: First Time Setup
- On your iPhone, you may see "Untrusted Developer" warning
- Go to: Settings → General → VPN & Device Management
- Tap on your developer certificate
- Tap "Trust [Your Name]"
- Return to the app and it should launch

## Method 2: Using Xcode

### Step 1: Open Xcode
```bash
open /Users/asadkathia/Desktop/Ustahub-1/Ustahub/ios/Runner.xcworkspace
```

### Step 2: Select Your Device
1. At the top of Xcode, click the device selector (next to the Run button)
2. Select "Asad's iPhone" from the list

### Step 3: Configure Signing (if needed)
1. Select "Runner" in the left sidebar
2. Go to "Signing & Capabilities" tab
3. Select your Team (or use "Automatically manage signing")
4. Xcode will handle code signing automatically

### Step 4: Build and Run
1. Click the **Play** button (▶️) or press `Cmd + R`
2. Xcode will build and install on your device
3. First time: Trust the developer on your iPhone (see Method 1, Step 3)

## Method 3: Build IPA and Install via Xcode

### Step 1: Build for Device
```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub/ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="Apple Development" \
  DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
  PROVISIONING_PROFILE_SPECIFIER=""
```

### Step 2: Install via Xcode
- Open Xcode
- Window → Devices and Simulators
- Select your iPhone
- Drag the .app file to the "Installed Apps" section

## Testing Notifications on Real Device

### Important Notes:
1. **Push notifications work better on real devices** than simulators
2. **Make sure your iPhone is connected to the internet** (WiFi or cellular)
3. **Grant notification permissions** when the app asks
4. **Check notification settings**: Settings → Notifications → Ustahub → Allow Notifications

### Test Checklist:
- [ ] App launches successfully
- [ ] Notification permission is granted
- [ ] FCM token is stored (check Supabase `fcm_tokens` table)
- [ ] Create booking → Provider receives notification
- [ ] Send message → Recipient receives notification
- [ ] Booking actions → Consumer receives notifications

## Troubleshooting

### "Device not found"
- Make sure iPhone is unlocked
- Check USB cable connection
- Try disconnecting and reconnecting
- Restart Xcode/Flutter

### "Untrusted Developer"
- Settings → General → VPN & Device Management
- Trust your developer certificate

### "Code signing error"
- Open Xcode → Runner → Signing & Capabilities
- Select your Apple ID/Team
- Enable "Automatically manage signing"

### "App won't install"
- Check iPhone storage space
- Make sure iPhone is not in Low Power Mode
- Restart iPhone and try again

## Quick Command Reference

```bash
# List devices
flutter devices
xcrun xctrace list devices

# Run on specific device
flutter run -d <device-id>

# Build for device
flutter build ios --debug

# Install via Xcode
open ios/Runner.xcworkspace
```


