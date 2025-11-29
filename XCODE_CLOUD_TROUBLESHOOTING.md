# Xcode Cloud Troubleshooting Guide

## Current Issue

Build is failing with these errors:
- `could not find included file 'Generated.xcconfig' in search paths`
- Multiple "Unable to load contents of file list" errors for CocoaPods files

## Solution Applied

Created `ci_scripts/ci_post_clone.sh` that:
1. Installs Flutter SDK (if needed)
2. Runs `flutter pub get` to generate `Generated.xcconfig`
3. Runs `pod install` to create CocoaPods file lists

## Verification Steps

### 1. Check Script is Committed
```bash
git log --oneline --all | grep -i "xcode\|ci"
```

### 2. Verify Script Location
The script must be at: `ci_scripts/ci_post_clone.sh` (repository root)

### 3. Check Script Permissions
```bash
ls -la ci_scripts/ci_post_clone.sh
# Should show: -rwxr-xr-x (executable)
```

### 4. View Xcode Cloud Logs

In App Store Connect:
1. Go to your app → Xcode Cloud → Builds
2. Click on the failed build
3. Click "Archive - iOS" → "Logs"
4. Look for "Post-Clone Script" section
5. Check if you see: "🚀 Xcode Cloud Post-Clone Script Started"

**If you DON'T see the script output:**
- The script isn't being detected
- Check that it's committed and pushed
- Verify the path is exactly `ci_scripts/ci_post_clone.sh`

**If you DO see the script output but it fails:**
- Check the error messages in the logs
- The script will show detailed error messages

## Common Issues

### Issue: Script Not Running

**Symptoms:** No script output in logs

**Solutions:**
1. Ensure script is committed: `git status ci_scripts/`
2. Ensure script is at root: `ci_scripts/ci_post_clone.sh` (not in a subdirectory)
3. Ensure script has execute permissions (should be automatic on commit)
4. Push to the branch that Xcode Cloud monitors

### Issue: Flutter Not Found

**Symptoms:** Script runs but `flutter: command not found`

**Solutions:**
- The script installs Flutter automatically
- If it fails, check network connectivity in Xcode Cloud logs
- Flutter installation may take a few minutes

### Issue: Generated.xcconfig Still Missing

**Symptoms:** Script completes but build still fails with "could not find included file 'Generated.xcconfig'"

**Solutions:**
1. Check script logs to see if `flutter pub get` ran successfully
2. Verify `ios/Flutter/` directory exists
3. The script explicitly checks for this file and will fail if it's not created

### Issue: CocoaPods Files Still Missing

**Symptoms:** Script completes but build fails with "Unable to load contents of file list"

**Solutions:**
1. Check script logs to see if `pod install` ran successfully
2. Verify `ios/Pods/` directory was created
3. The script verifies required files exist
4. If files are missing, check CocoaPods version compatibility

## Manual Testing

Test the script locally to verify it works:

```bash
# Clean environment (optional)
rm -rf ios/Pods ios/Podfile.lock ios/Flutter/Generated.xcconfig

# Run the script
./ci_scripts/ci_post_clone.sh

# Verify files were created
ls -la ios/Flutter/Generated.xcconfig
ls -la "ios/Pods/Target Support Files/Pods-Runner/"*.xcfilelist
```

## Next Steps After Fix

1. **Commit the updated script:**
   ```bash
   git add ci_scripts/ci_post_clone.sh
   git commit -m "Improve Xcode Cloud post-clone script with better error handling"
   git push
   ```

2. **Trigger a new build in Xcode Cloud:**
   - Go to App Store Connect → Xcode Cloud
   - Click "Rebuild" on your workflow

3. **Monitor the build:**
   - Watch the build logs in real-time
   - Look for the script output messages
   - Verify all steps complete successfully

## Additional Resources

- [Xcode Cloud Documentation](https://developer.apple.com/documentation/xcode)
- [Flutter iOS Setup](https://docs.flutter.dev/deployment/ios)
- [CocoaPods Documentation](https://guides.cocoapods.org/)

