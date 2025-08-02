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

1. Download the shader files
2. Place them in your ReShade shaders directory
3. Enable the shaders in ReShade

## Usage

1. Install ReShade in your game
2. Add the capture and compare shaders
3. Run the `ProcessVideos.bat` script to process your recordings

## Requirements

- ReShade
- A game that supports depth buffer access
- Video processing software (for batch processing)

## Contributing

Feel free to submit issues and enhancement requests!

## License

[Add your license information here]

---

*Created by wblndr* 