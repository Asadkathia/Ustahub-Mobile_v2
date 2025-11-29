# Xcode Cloud Setup for Flutter iOS

This document explains the Xcode Cloud configuration for building the UstaHub iOS app.

## Overview

Xcode Cloud requires special setup for Flutter projects because:
1. Flutter SDK needs to be installed
2. Flutter dependencies must be fetched (`flutter pub get`)
3. CocoaPods dependencies must be installed (`pod install`)
4. Flutter generates `Generated.xcconfig` which is required by the build

## Files Created

### `ci_scripts/ci_post_clone.sh`

This script runs automatically after Xcode Cloud clones your repository and before the build starts. It:

1. **Installs Flutter SDK** (if not already in PATH)
2. **Runs `flutter pub get`** to fetch Flutter dependencies and generate `Generated.xcconfig`
3. **Runs `pod install`** to install CocoaPods dependencies
4. **Verifies** that all required files are present

## Required Git Commits

Make sure the following are committed to your repository:

- ✅ `ci_scripts/ci_post_clone.sh` (the script itself)
- ✅ `ios/Podfile` (CocoaPods configuration)
- ✅ `ios/Podfile.lock` (recommended - locks dependency versions)
- ✅ `pubspec.yaml` (Flutter dependencies)
- ✅ `ios/Flutter/Release.xcconfig` (references Generated.xcconfig)

**Note:** `ios/Flutter/Generated.xcconfig` is generated during the build and should NOT be committed.

## Xcode Cloud Configuration

1. **In App Store Connect:**
   - Go to your app → Xcode Cloud
   - Create or edit your workflow
   - The `ci_scripts/ci_post_clone.sh` script will be automatically detected and run

2. **Build Settings:**
   - Ensure your Xcode Cloud workflow is configured to build the iOS scheme
   - The archive action should target "iOS" platform

## Troubleshooting

### Error: "Unable to load contents of file list"

This means CocoaPods file lists are missing. The `ci_post_clone.sh` script should fix this by running `pod install`.

### Error: "could not find included file 'Generated.xcconfig'"

This means Flutter hasn't generated the config file. The script runs `flutter pub get` which generates this file.

### Build Still Fails

1. Check the build logs in App Store Connect
2. Verify the `ci_post_clone.sh` script executed successfully
3. Ensure all required files are committed to your repository
4. Check that `Podfile.lock` is committed (recommended for consistent builds)

## Testing Locally

You can test the script locally:

```bash
cd /path/to/project
./ci_scripts/ci_post_clone.sh
```

## Next Steps

1. Commit the `ci_scripts/ci_post_clone.sh` file to your repository
2. Push to the branch that Xcode Cloud is monitoring
3. Trigger a new build in Xcode Cloud
4. Monitor the build logs to verify the script runs successfully

