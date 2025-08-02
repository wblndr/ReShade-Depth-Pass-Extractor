# ReShade Depth Pass Extractor

A tool for extracting depth passes from ReShade shaders and creating side-by-side comparison videos.

## Overview

This project provides tools and shaders for extracting depth information from games using ReShade, allowing you to create depth pass visualizations and comparisons.

## Files

- **`ProcessVideos.bat`** - Batch script for processing video files
- **`reshade-shaders/Shaders/_blndr/01_Capture.fx`** - ReShade shader for capturing depth data
- **`reshade-shaders/Shaders/_blndr/99_Compare.fx`** - ReShade shader for comparing depth passes
- **`sidebyside.ini`** - Configuration file for side-by-side video processing

## Installation

### Prerequisites
- ReShade installed in your game
- A game that supports depth buffer access (most modern games)
- FFmpeg installed on your system (for video processing)

### Step-by-Step Installation
1. **Download the shader files** from this repository
2. **Locate your ReShade shaders directory**:
   - Usually found in: `[Game Directory]/reshade-shaders/Shaders/`
   - Or in ReShade's global shader directory
3. **Copy the shader files**:
   - Copy `01_Capture.fx` and `99_Compare.fx` to your shaders folder
   - You can create a `_blndr` subfolder to organize them
4. **Restart your game** to load the new shaders

## Usage

### Setting Up Depth Capture
1. **Launch your game** with ReShade enabled
2. **Open ReShade overlay** (usually `Home` key)
3. **Enable the shaders**:
   - Find and enable `01_Capture.fx` for depth capture
   - Find and enable `99_Compare.fx` for side-by-side comparison
4. **Configure shader settings** as needed for your specific game

### Recording and Processing
1. **Record gameplay** with the depth capture shader active
2. **Save your recordings** in a folder accessible to the batch script
3. **Run `ProcessVideos.bat`**:
   - Double-click the batch file
   - Or run it from command line: `ProcessVideos.bat [input_folder] [output_folder]`
4. **Check the output** for processed side-by-side comparison videos

### Configuration
- Edit `sidebyside.ini` to customize video processing settings
- Modify shader parameters in-game through ReShade overlay
- Adjust batch script parameters for different video formats

## Requirements

### Software Requirements
- **ReShade** - Latest version recommended
- **FFmpeg** - For video processing (download from [ffmpeg.org](https://ffmpeg.org))
- **A game that supports depth buffer access** - Most modern games work

### System Requirements
- Windows 10/11 (for batch script compatibility)
- Sufficient disk space for video processing
- Graphics card that supports ReShade

## Troubleshooting

### Common Issues
- **Shaders not appearing**: Make sure files are in the correct directory and game is restarted
- **Depth buffer not working**: Some games require specific ReShade settings or compatibility mode
- **Batch script errors**: Ensure FFmpeg is installed and in your system PATH
- **Poor performance**: Try reducing shader complexity or game settings

### Getting Help
- Check that your game supports depth buffer access
- Verify ReShade is properly installed and working
- Ensure all file paths in the batch script are correct

## Contributing

Feel free to submit issues and enhancement requests!

## License

[Add your license information here]

---

*Created by wblndr* 