# ReShade SBS WFX
A workflow for creating Side-by-Side (SBS) video passes with ReShade.

## Prerequisites
-   ReShade installed in your game.
-   FFmpeg installed on your system. The script will guide you if it's missing, but the easiest way is to install it via winget:
    ```powershell
    winget install "FFmpeg (Essentials Build)"
    ```

## How to Use

### Installation

1.  **Download the files** from this repository.
2.  **Copy the `reshade-shaders` folder** into your game's root directory where the game's `.exe` file is located. This will place the `.fx` files in `[Game Directory]/reshade-shaders/Shaders/SBS-WFX/`.
3.  **Start your game** and open the ReShade overlay (usually the `Home` key).
4.  **Set the Shader Order:**
    -   Drag **`START_WorldCapture`** to the very **top** of your active shader list.
    -   Drag **`END_SideBySideOutput`** to the very **bottom** of the list.
    -   Place any shaders you want to extract (e.g., `DisplayDepth.fx`) in between.
5.  You should now see a side-by-side view in your game. You are ready to record!

### Processing Your Videos
The `VideoSplitter.bat` script has two modes:

1.  **Watcher Mode (Recommended):**
    -   Configure the script by editing the variables in the `CONFIGURATION` section.
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

## Configuring `VideoSplitter.bat`
All configuration is done by editing the `VideoSplitter.bat` file in a text editor. The settings are clearly laid out in the `CONFIGURATION` section at the top of the file.

### Core Paths
*   `VIDEO_SOURCE_DIR`: The folder the script will monitor for new video files when in **Watcher Mode**.
*   `OUTPUT_SUBFOLDER_NAME`: The name of the subfolder that will be created inside the source directory to store the processed video passes (e.g., `MyVideos/Passes/`).
*   `PROCESSED_ORIGINALS_SUBFOLDER`: The name of the subfolder where original video files will be moved after successful processing.

### Processing
*   `WORLD_ON_RIGHT`: This is the most important setting. It **must match** the "World on Right" checkbox in the ReShade preset.
    *   `true`: The world/beauty pass is on the right side of the recorded video.
    *   `false`: The world/beauty pass is on the left side.
*   `KEEP_ORIGINAL_CODEC`:
    *   `true`: The script will not re-encode the video. The output files will have the same codec and container as the original. This is faster but may result in larger files.
    *   `false`: The script will convert the videos to high-quality editing formats (ProRes for both the world and depth passes).
*   `REMOVE_AUDIO`:
    *   `true`: Audio will be stripped from all output files.
    *   `false`: Audio from the original recording will be kept in the main world pass file.

### File Naming & Handling
*   `OUTPUT_WORLD_SUFFIX`: The text added to the end of the world pass filename (e.g., `myvideo_world.mov`).
*   `OUTPUT_DEPTH_SUFFIX`: The text added to the end of the depth pass filename (e.g., `myvideo_depth.mov`).
*   `OUTPUT_EXTENSION`: The file extension used when `KEEP_ORIGINAL_CODEC` is `false` (default is `.mov`).
*   `VIDEO_EXTENSIONS`: A space-separated list of file extensions that the script should look for in Watcher Mode (e.g., `.mp4 .mov .mkv`).
*   `MOVE_ORIGINAL_ON_SUCCESS`:
    *   `true`: The original video file will be moved to the `PROCESSED_ORIGINALS_SUBFOLDER` after it has been successfully split.
    *   `false`: The original video file will be left in the source directory.

### Watcher Mode
*   `CHECK_INTERVAL_SECONDS`: How many seconds the script waits between scanning the `VIDEO_SOURCE_DIR` for new files.

## Troubleshooting
-   **Shaders not appearing:** Ensure they are in the correct `reshade-shaders/Shaders` directory and that you have restarted your game.
-   **Batch script errors:** Make sure FFmpeg is installed and accessible in your system's PATH. The script has a built-in check that will alert you if it can't find it.
-   **Incorrect output:** Double-check that the `World on Right` setting in the `END_SideBySideOutput` shader matches the `WORLD_ON_RIGHT` variable in `VideoSplitter.bat`.

## Contributing
Feel free to open an issue to report bugs or suggest features.