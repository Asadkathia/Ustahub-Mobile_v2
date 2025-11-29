# App Store Screenshot Guide

## Required Dimensions for iPhone 6.5" Display

The App Store requires screenshots in one of these dimensions:

**Portrait (Recommended):**
- `1242 x 2688px` (iPhone XS Max, 11 Pro Max, 12 Pro Max, 13 Pro Max)
- `1284 x 2778px` (iPhone 14 Plus, 15 Plus, 16 Plus)

**Landscape:**
- `2688 x 1242px` (iPhone XS Max, 11 Pro Max, 12 Pro Max, 13 Pro Max)
- `2778 x 1284px` (iPhone 14 Plus, 15 Plus, 16 Plus)

## Quick Solutions

### Option 1: Use the Automated Script

Run the helper script:
```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub
./scripts/prepare_app_store_screenshots.sh
```

This script will:
- Take screenshots from the simulator
- Resize existing screenshots to correct dimensions
- Save them in `app_store_screenshots/` folder

### Option 2: Quick Resize Command (Single Image)

If you already have a screenshot and just need to resize it:

**For Portrait (1242 x 2688px):**
```bash
sips -z 2688 1242 your_screenshot.png --out app_store_screenshots/screenshot_portrait_1242x2688.png
```

**For Landscape (2688 x 1242px):**
```bash
sips -z 1242 2688 your_screenshot.png --out app_store_screenshots/screenshot_landscape_2688x1242.png
```

### Option 3: Take Screenshot from Simulator

1. **Boot the correct simulator:**
```bash
xcrun simctl boot C37D6581-FF8C-45D8-9F0E-DB003C76B0A3  # iPhone 16 Plus
```

2. **Launch your app:**
```bash
xcrun simctl launch C37D6581-FF8C-45D8-9F0E-DB003C76B0A3 com.asadkathia.ustahubb.dev
```

3. **Take screenshot:**
```bash
xcrun simctl io C37D6581-FF8C-45D8-9F0E-DB003C76B0A3 screenshot app_store_screenshots/screenshot.png
```

4. **Resize if needed:**
```bash
sips -z 2688 1242 app_store_screenshots/screenshot.png --out app_store_screenshots/screenshot_1242x2688.png
```

### Option 4: Using Simulator UI

1. Open Simulator app
2. Boot iPhone 15 Plus or iPhone 16 Plus (6.5" display)
3. Launch your app
4. Navigate to the screen you want to screenshot
5. Use **Device → Screenshot** (or `Cmd + S`)
6. The screenshot will be saved to your Desktop
7. Resize using the commands above if needed

## Batch Resize Multiple Screenshots

If you have multiple screenshots to resize:

```bash
mkdir -p app_store_screenshots
for img in path/to/your/screenshots/*.png; do
    filename=$(basename "$img" | sed 's/\.[^.]*$//')
    sips -z 2688 1242 "$img" --out "app_store_screenshots/${filename}_1242x2688.png"
done
```

## Verify Dimensions

Check the dimensions of your screenshot:
```bash
sips -g pixelWidth -g pixelHeight your_screenshot.png
```

## Tips

1. **Use Portrait Orientation**: App Store Connect typically prefers portrait screenshots for the 6.5" display
2. **First 3 Screenshots**: Only the first 3 screenshots are used on the app installation sheet
3. **Quality**: Make sure screenshots are high quality and showcase your app's key features
4. **Test on Device**: Consider taking screenshots from a real device for best quality

## Common Issues

**Issue**: "The dimensions of one or more screenshots are wrong"
**Solution**: Use the resize commands above to ensure exact dimensions match one of the required sizes

**Issue**: Screenshots look stretched or distorted
**Solution**: Make sure you're maintaining the aspect ratio. The script uses `sips -z` which maintains aspect ratio, but you may need to crop first.

