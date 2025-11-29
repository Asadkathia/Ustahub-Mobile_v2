#!/bin/bash

# Script to prepare App Store screenshots with correct dimensions
# Required dimensions for iPhone 6.5" Display:
# - Portrait: 1242 x 2688px or 1284 x 2778px
# - Landscape: 2688 x 1242px or 2778 x 1284px

SCREENSHOT_DIR="app_store_screenshots"
PORTRAIT_WIDTH=1242
PORTRAIT_HEIGHT=2688
LANDSCAPE_WIDTH=2688
LANDSCAPE_HEIGHT=1242

# Alternative dimensions (for newer iPhones)
PORTRAIT_WIDTH_ALT=1284
PORTRAIT_HEIGHT_ALT=2778
LANDSCAPE_WIDTH_ALT=2778
LANDSCAPE_HEIGHT_ALT=1284

echo "📸 App Store Screenshot Preparation Tool"
echo "=========================================="
echo ""

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"

# Function to resize an image
resize_image() {
    local input_file="$1"
    local output_file="$2"
    local width="$3"
    local height="$4"
    
    if [ ! -f "$input_file" ]; then
        echo "❌ Error: File not found: $input_file"
        return 1
    fi
    
    echo "🔄 Resizing $input_file to ${width}x${height}..."
    sips -z "$height" "$width" "$input_file" --out "$output_file" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Created: $output_file"
        return 0
    else
        echo "❌ Failed to resize $input_file"
        return 1
    fi
}

# Function to take screenshot from simulator
take_simulator_screenshot() {
    local device_id="$1"
    local output_file="$2"
    
    echo "📱 Taking screenshot from simulator..."
    xcrun simctl io "$device_id" screenshot "$output_file"
    
    if [ $? -eq 0 ]; then
        echo "✅ Screenshot saved: $output_file"
        
        # Get dimensions
        local dimensions=$(sips -g pixelWidth -g pixelHeight "$output_file" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}')
        echo "📐 Current dimensions: $dimensions"
        
        return 0
    else
        echo "❌ Failed to take screenshot"
        return 1
    fi
}

# Main menu
echo "Choose an option:"
echo "1) Take new screenshots from simulator"
echo "2) Resize existing screenshots"
echo "3) Both (take and resize)"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "📱 Available simulators:"
        xcrun simctl list devices | grep -E "iPhone.*Plus|iPhone.*Pro Max" | grep -v "unavailable"
        echo ""
        read -p "Enter device ID (or press Enter to use iPhone 16 Plus): " device_id
        if [ -z "$device_id" ]; then
            device_id="C37D6581-FF8C-45D8-9F0E-DB003C76B0A3"  # iPhone 16 Plus
        fi
        
        read -p "Enter screenshot name (e.g., screenshot1): " screenshot_name
        if [ -z "$screenshot_name" ]; then
            screenshot_name="screenshot_$(date +%Y%m%d_%H%M%S)"
        fi
        
        output_file="$SCREENSHOT_DIR/${screenshot_name}.png"
        take_simulator_screenshot "$device_id" "$output_file"
        ;;
    
    2)
        echo ""
        read -p "Enter path to screenshot file or directory: " input_path
        
        if [ -d "$input_path" ]; then
            # Process all images in directory
            echo "📁 Processing all images in directory: $input_path"
            count=1
            for img in "$input_path"/*.{png,jpg,jpeg,PNG,JPG,JPEG} 2>/dev/null; do
                if [ -f "$img" ]; then
                    filename=$(basename "$img" | sed 's/\.[^.]*$//')
                    resize_image "$img" "$SCREENSHOT_DIR/${filename}_portrait_${PORTRAIT_WIDTH}x${PORTRAIT_HEIGHT}.png" "$PORTRAIT_WIDTH" "$PORTRAIT_HEIGHT"
                    resize_image "$img" "$SCREENSHOT_DIR/${filename}_landscape_${LANDSCAPE_WIDTH}x${LANDSCAPE_HEIGHT}.png" "$LANDSCAPE_WIDTH" "$LANDSCAPE_HEIGHT"
                    count=$((count + 1))
                fi
            done
        elif [ -f "$input_path" ]; then
            # Process single file
            filename=$(basename "$input_path" | sed 's/\.[^.]*$//')
            echo "📄 Processing single file: $input_path"
            resize_image "$input_path" "$SCREENSHOT_DIR/${filename}_portrait_${PORTRAIT_WIDTH}x${PORTRAIT_HEIGHT}.png" "$PORTRAIT_WIDTH" "$PORTRAIT_HEIGHT"
            resize_image "$input_path" "$SCREENSHOT_DIR/${filename}_landscape_${LANDSCAPE_WIDTH}x${LANDSCAPE_HEIGHT}.png" "$LANDSCAPE_WIDTH" "$LANDSCAPE_HEIGHT"
        else
            echo "❌ Error: Path not found: $input_path"
            exit 1
        fi
        ;;
    
    3)
        echo ""
        echo "📱 Taking screenshot from simulator..."
        device_id="C37D6581-FF8C-45D8-9F0E-DB003C76B0A3"  # iPhone 16 Plus
        temp_file="$SCREENSHOT_DIR/temp_screenshot.png"
        take_simulator_screenshot "$device_id" "$temp_file"
        
        if [ -f "$temp_file" ]; then
            filename="screenshot_$(date +%Y%m%d_%H%M%S)"
            resize_image "$temp_file" "$SCREENSHOT_DIR/${filename}_portrait_${PORTRAIT_WIDTH}x${PORTRAIT_HEIGHT}.png" "$PORTRAIT_WIDTH" "$PORTRAIT_HEIGHT"
            resize_image "$temp_file" "$SCREENSHOT_DIR/${filename}_landscape_${LANDSCAPE_WIDTH}x${LANDSCAPE_HEIGHT}.png" "$LANDSCAPE_WIDTH" "$LANDSCAPE_HEIGHT"
            rm "$temp_file"
        fi
        ;;
    
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "✅ Done! Screenshots are in: $SCREENSHOT_DIR"
echo ""
echo "📋 Required dimensions for App Store:"
echo "   Portrait: ${PORTRAIT_WIDTH} x ${PORTRAIT_HEIGHT}px or ${PORTRAIT_WIDTH_ALT} x ${PORTRAIT_HEIGHT_ALT}px"
echo "   Landscape: ${LANDSCAPE_WIDTH} x ${LANDSCAPE_HEIGHT}px or ${LANDSCAPE_WIDTH_ALT} x ${LANDSCAPE_HEIGHT_ALT}px"
echo ""
echo "💡 Tip: Upload portrait screenshots for the iPhone 6.5\" Display section"

