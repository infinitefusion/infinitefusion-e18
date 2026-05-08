#!/bin/bash

# Ensure we are in the script's directory
cd "$(dirname "$0")"

# Configuration
VERSION=$(date +%Y-%m-%d_%H-%M)
RELEASE_DIR="InfiniteFusion_Release_$VERSION"
ZIP_NAME="InfiniteFusion_$VERSION.zip"
OUTPUT_FOLDER="Releases"

echo "--- Working directory: $(pwd) ---"
echo "--- Starting packaging process for $RELEASE_DIR ---"

# 1. Setup Directories
mkdir -p "$RELEASE_DIR"
mkdir -p "$OUTPUT_FOLDER"

# 2. Define Assets
FOLDERS=("Audio" "Data" "Fonts" "Graphics")
FILES=(
    ".nomedia"
    "Credits.txt" 
    "Game.ini" 
    "InfiniteFusion.exe" 
    "InfiniteFusion-performance.exe" 
    "mkxp.json" 
    "README.md" 
    "RGSS100J.dll" 
    "RGSS104E.dll" 
    "x64-msvcrt-ruby300.dll" 
    "x64-msvcrt-ruby310.dll" 
    "zlib1.dll"
    "Savefile.lnk"
)

# 3. Copy Folders
echo "Copying folders..."
for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        cp -r "$folder" "$RELEASE_DIR/"
        echo "OK: $folder"
    else
        echo "Warning: Folder $folder not found."
    fi
done

# 4. Copy Files
echo "Copying files..."
for file in "${FILES[@]}"; do
    if [ -f "$file" ] || [ -L "$file" ]; then
        cp "$file" "$RELEASE_DIR/"
        echo "OK: $file"
    else
        echo "Warning: File $file not found."
    fi
done

# 5. Create the Zip Archive
echo "Creating zip archive..."
zip -r "$ZIP_NAME" "$RELEASE_DIR"

# 6. Move to Releases and Cleanup
mv "$ZIP_NAME" "$OUTPUT_FOLDER/"
rm -rf "$RELEASE_DIR"

echo "--- Done! Zip moved to: $OUTPUT_FOLDER/$ZIP_NAME ---"