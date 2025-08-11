# ReShade Side-by-Side Video Extractor

This project provides a set of ReShade shaders and a Windows batch script to capture and process side-by-side videos from any game running ReShade. It's designed to extract a "clean" world pass and a second pass (like a depth map, normal map, etc.) from a single recording, saving them as separate, high-quality video files.

This workflow is ideal for VFX, motion graphics, and game art, allowing you to use in-game footage as a source for post-production work.



## Prerequisites
-   ReShade installed in your game.
-   FFmpeg installed on your system. The script will guide you if it's missing, but the easiest way is to install it via winget:
    ```powershell
    winget install "FFmpeg (Essentials Build)"
    ```

## How to Use

### Installation

**Note:** You will need to configure your ReShade shaders manually by following the steps below. A pre-configured preset file is not provided.

1.  **Download the files** from this repository.
2.  **Copy the `reshade-shaders` folder** into your game's root directory where the game's `.exe` file is located. This will place the `.fx` files in `[Game Directory]/reshade-shaders/Shaders/_blndr/`.
3.  **Start your game** and open the ReShade overlay (usually the `Home` key).
4.  **Set the Shader Order:**
    -   Drag **`START_WorldCapture`** to the very **top** of your active shader list.
    -   Drag **`END_SideBySideOutput`** to the very **bottom** of the list.
    -   Place any shaders you want to extract (e.g., `DisplayDepth.fx`) in between.
5.  You should now see a side-by-side view in your game. You are ready to record!

### Processing Your Videos
The `VideoSplitter.bat` script has two modes:

1.  **Watcher Mode (Recommended):**
    -   Configure the `VIDEO_SOURCE_DIR` variable inside the script to point to your recordings folder.
    -   Simply double-click the `.bat` file to run it.
    -   It will continuously watch the folder for new videos and process them automatically. This is great for batch processing.

2.  **Drag-and-Drop Mode:**
    -   Drag a single video file directly onto the `VideoSplitter.bat` icon.
    -   The script will process just that one file.

### Shader Configuration
The `END_SideBySideOutput` shader has a few options in the ReShade UI:
-   **World on Right:** Check this box if you want to swap the positions of the world pass and the effect pass. **This setting must match the `WORLD_ON_RIGHT` variable in the batch script!**
-   **Display Mode:** Changes how the two passes are compared (e.g., split screen, centered overlay).
-   **Invert Depth:** A utility to flip the colors of the effect pass, which can be useful for depth maps.

## ProcessVideos Codec Configuration

The batch script is pre-configured for high-quality, professional video formats suitable for post-production. You can, however, change these settings by editing `VideoSplitter.bat`.

### Default Codecs
-   **World Pass (`_world.mov`):** `ProRes 422 HQ`
    -   **Why:** Excellent quality, widely supported in video editing software, and visually lossless. Great for color grading.
-   **Other Pass (`_depth.mov`):** `QuickTime Animation (QTRLE)`
    -   **Why:** Mathematically lossless. This is critical for data passes like depth or normal maps, where every single color value is important and must not be altered by compression.

### How to Change Codecs
1.  Open `VideoSplitter.bat` in a text editor.
2.  Find the line that starts with `"%FFMPEG_EXE%" -i "%INPUT_FILE%" ...`.
3.  The world pass codec is defined by `-c:v prores_ks -profile:v 3 ...`.
4.  The other pass codec is defined by `-c:v qtrle`.
5.  You can replace these with other FFmpeg-supported codecs. For a comprehensive list of available codecs and their options, refer to the [official FFmpeg documentation](https://ffmpeg.org/ffmpeg-codecs.html).

## Troubleshooting
-   **Shaders not appearing:** Ensure they are in the correct `reshade-shaders/Shaders` directory and that you have restarted your game.
-   **Batch script errors:** Make sure FFmpeg is installed and accessible in your system's PATH. The script has a built-in check that will alert you if it can't find it.
-   **Incorrect output:** Double-check that the `World on Right` setting in the `END_SideBySideOutput` shader matches the `WORLD_ON_RIGHT` variable in `VideoSplitter.bat`.

## Contributing
Feel free to open an issue to report bugs or suggest features.

---
*Created by wblndr*