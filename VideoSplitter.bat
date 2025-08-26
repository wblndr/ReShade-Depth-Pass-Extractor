@echo off
setlocal enabledelayedexpansion

:: ################################################################################################
:: ###                                    CONFIGURATION                                         ###
:: ################################################################################################

:: -- Core Paths --
set "VIDEO_SOURCE_DIR=%USERPROFILE%\Videos\Depth_ToProcess"  :: Folder to watch for new videos.
set "OUTPUT_SUBFOLDER_NAME=Passes"                          :: Subfolder for the processed video passes.
set "PROCESSED_ORIGINALS_SUBFOLDER=Originals_Processed"     :: Subfolder for original files after processing.

:: -- Processing --
set "WORLD_ON_RIGHT=false"       :: true = World on Right, false = World on Left.
set "KEEP_ORIGINAL_CODEC=false"  :: true = Keep original codec/container, false = Convert to ProRes/QTRLE.
set "REMOVE_AUDIO=false"         :: true = Remove audio from all outputs, false = Keep in main output.

:: -- File Naming & Handling --
set "OUTPUT_WORLD_SUFFIX=_world"          :: Suffix for the world pass file.
set "OUTPUT_DEPTH_SUFFIX=_depth"          :: Suffix for the depth pass file.
set "OUTPUT_EXTENSION=.mov"               :: Output extension when converting (KEEP_ORIGINAL_CODEC=false).
set "VIDEO_EXTENSIONS=.mp4 .mov .mkv .avi .mxf" :: Video file types to look for.
set "MOVE_ORIGINAL_ON_SUCCESS=true"       :: true = Move original file after processing.

:: -- Watcher Mode --
set "CHECK_INTERVAL_SECONDS=60"  :: How often to scan the source folder (in seconds).

:: ################################################################################################
:: ###                                 END OF CONFIGURATION                                     ###
:: ################################################################################################


:: --- Script Initialization ---

:: Step 1: Check for a system-wide FFmpeg installation first.
echo [INFO] Checking for system-wide FFmpeg installation...
ffmpeg -version >nul 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] System-wide FFmpeg found.
    set "FFMPEG_EXE=ffmpeg"
) else (
    echo [WARNING] System-wide FFmpeg not found. Checking for a local ffmpeg.exe...
    set "LOCAL_FFMPEG_PATH=%~dp0ffmpeg.exe"
    if exist "%LOCAL_FFMPEG_PATH%" (
        "%LOCAL_FFMPEG_PATH%" -version >nul 2>nul
        if !errorlevel! equ 0 (
            echo [SUCCESS] Local ffmpeg.exe found and will be used.
            set "FFMPEG_EXE=%LOCAL_FFMPEG_PATH%"
        ) else (
            goto :ffmpeg_error
        )
    ) else (
        goto :ffmpeg_error
    )
)
echo [INFO] Using FFmpeg executable at: "%FFMPEG_EXE%"
echo.
goto :start_script

:ffmpeg_error
cls
echo ========================================================================
echo [CRITICAL ERROR] FFmpeg is not installed or could not be found.
echo ========================================================================
echo.
echo This script requires FFmpeg to function. Please choose one of the
echo following solutions:
echo.
echo ------------------------------------------------------------------------
echo SOLUTION 1 (RECOMMENDED): Install FFmpeg on your system.
echo ------------------------------------------------------------------------
echo Open a Windows Terminal (as Administrator) and run this command:
echo.
echo    winget install "FFmpeg (Essentials Build)"
echo.
echo After installation, please restart this script.
echo.
echo ------------------------------------------------------------------------
echo SOLUTION 2 (LAST RESORT): Manual Download
echo ------------------------------------------------------------------------
echo 1. Go to the official FFmpeg website: https://ffmpeg.org/download.html
echo 2. Under the Windows logo, click one of the build provider links
echo    (e.g., "gyan.dev" or "BtbN").
echo 3. Download the "essentials" build .zip file.
echo 4. Unzip the file and place 'ffmpeg.exe' in this exact folder:
echo    "%~dp0"
echo.
echo ------------------------------------------------------------------------
echo.
pause
exit /b 1

:start_script
:: --- Mode Selection ---
if not "%~1"=="" (
    goto :ManualMode
) else (
    goto :WatcherMode
)


:: ################################################################################################
:: ###                                 MANUAL / DRAG-DROP MODE                                  ###
:: ################################################################################################
:ManualMode
cls
echo ============================================================
echo  Manual Processing Mode
echo ============================================================
echo.
echo [REMINDER] Ensure the 'WorldOnRight' setting in this script
echo [REMINDER] matches the checkbox setting in your ReShade preset!
echo.
echo [INFO] Processing a single file: "%~f1"
echo.
call :ProcessSingleFile "%~f1"
echo.
if !errorlevel! neq 0 (
    echo [ERROR] --- Processing FAILED. Check messages above. ---
) else (
    echo [SUCCESS] --- Processing SUCCEEDED. ---
)
echo.
echo Press any key to exit.
pause >nul
exit /b !errorlevel!


:: ################################################################################################
:: ###                                    FOLDER WATCHER MODE                                   ###
:: ################################################################################################
:WatcherMode
cls
echo ============================================================
echo  Video Processor Watcher
echo ============================================================
echo.
echo [INFO] Monitoring Folder: %VIDEO_SOURCE_DIR%
echo [INFO] Check Interval:    %CHECK_INTERVAL_SECONDS% seconds
echo [INFO] Move Originals:    %MOVE_ORIGINAL_ON_SUCCESS%
echo.
echo [REMINDER] Ensure the 'WorldOnRight' setting in this script
echo [REMINDER] matches the checkbox setting in your ReShade preset!
echo.
echo Press Ctrl+C to stop the watcher.
echo ============================================================
echo.
if not exist "%VIDEO_SOURCE_DIR%" (
    echo [ERROR] Video source directory "%VIDEO_SOURCE_DIR%" not found.
    echo [INFO] Please check the VIDEO_SOURCE_DIR variable in the configuration section.
    pause
    exit /b 1
)
:WatcherLoop
echo [%TIME%] [INFO] Scanning "%VIDEO_SOURCE_DIR%" for new videos...
for %%e in (%VIDEO_EXTENSIONS%) do (
    for /f "delims=" %%f in ('dir /b /a-d "%VIDEO_SOURCE_DIR%\*%%e" 2^>nul') do (
        set "INPUT_FILE_FULL_PATH=%VIDEO_SOURCE_DIR%\%%f"
        set "INPUT_FILE_NAME_NO_EXT=%%~nf"
        
        if /i "!KEEP_ORIGINAL_CODEC!" == "true" (
            set "CHECK_OUTPUT_FILE=%VIDEO_SOURCE_DIR%\%OUTPUT_SUBFOLDER_NAME%\!INPUT_FILE_NAME_NO_EXT!%OUTPUT_WORLD_SUFFIX%%%~xf"
        ) else (
            set "CHECK_OUTPUT_FILE=%VIDEO_SOURCE_DIR%\%OUTPUT_SUBFOLDER_NAME%\!INPUT_FILE_NAME_NO_EXT!%OUTPUT_WORLD_SUFFIX%%OUTPUT_EXTENSION%"
        )
        
        if not exist "!CHECK_OUTPUT_FILE!" (
            echo.
            echo [%TIME%] [INFO] Found new video: "%%f"
            call :ProcessSingleFile "!INPUT_FILE_FULL_PATH!"
            
            if !errorlevel! neq 0 (
                echo [%TIME%] [ERROR] Processing failed for "%%~nxf". The original file will not be moved.
            ) else (
                echo [%TIME%] [SUCCESS] Successfully processed "%%~nxf".
                if /i "!MOVE_ORIGINAL_ON_SUCCESS!" == "true" (
                    set "PROCESSED_DIR=%VIDEO_SOURCE_DIR%\%PROCESSED_ORIGINALS_SUBFOLDER%"
                    mkdir "!PROCESSED_DIR!" 2>nul
                    if exist "!PROCESSED_DIR!\" (
                        echo [%TIME%] [INFO] Moving original "!INPUT_FILE_FULL_PATH!" to "!PROCESSED_DIR!"
                        move /Y "!INPUT_FILE_FULL_PATH!" "!PROCESSED_DIR!\" >nul
                        if !errorlevel! neq 0 (
                            echo [%TIME%] [ERROR] Could not move original file "%%~nxf".
                        )
                    ) else (
                        echo [%TIME%] [ERROR] Could not create or find directory for processed originals: "!PROCESSED_DIR!"
                    )
                )
            )
            echo.
        )
    )
)
echo [%TIME%] [INFO] Scan complete. Waiting for %CHECK_INTERVAL_SECONDS% seconds...
timeout /t %CHECK_INTERVAL_SECONDS% /nobreak >nul
goto :WatcherLoop


:: ################################################################################################
:: ###                           CORE PROCESSING SUBROUTINE                                     ###
:: ################################################################################################
:ProcessSingleFile
set "INPUT_FILE=%~1"
set "INPUT_FILE_DIR=%~dp1"
set "INPUT_FILE_NAME_NO_EXT=%~n1"
set "INPUT_FILE_EXT=%~x1"
set "OUTPUT_PASSES_DIR=%INPUT_FILE_DIR%%OUTPUT_SUBFOLDER_NAME%"
if not exist "%OUTPUT_PASSES_DIR%" (
    mkdir "%OUTPUT_PASSES_DIR%"
)
if /i "!WORLD_ON_RIGHT!" == "true" (
    set "WORLD_CROP=iw/2:ih:iw/2:0"
    set "DEPTH_CROP=iw/2:ih:0:0"
) else (
    set "WORLD_CROP=iw/2:ih:0:0"
    set "DEPTH_CROP=iw/2:ih:iw/2:0"
)
if /i "!KEEP_ORIGINAL_CODEC!" == "true" (
    set "WORLD_VIDEO_OPTS=-c:v copy"
    set "DEPTH_VIDEO_OPTS=-c:v copy"
    set "CURRENT_OUTPUT_EXTENSION=!INPUT_FILE_EXT!"
) else (
    set "WORLD_VIDEO_OPTS=-c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -qscale:v 2"
    set "DEPTH_VIDEO_OPTS=-c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le -qscale:v 2"
    set "CURRENT_OUTPUT_EXTENSION=!OUTPUT_EXTENSION!"
)
set "OUTPUT_WORLD=%OUTPUT_PASSES_DIR%\%INPUT_FILE_NAME_NO_EXT%%OUTPUT_WORLD_SUFFIX%%CURRENT_OUTPUT_EXTENSION%"
set "OUTPUT_DEPTH=%OUTPUT_PASSES_DIR%\%INPUT_FILE_NAME_NO_EXT%%OUTPUT_DEPTH_SUFFIX%%CURRENT_OUTPUT_EXTENSION%"
if /i "!REMOVE_AUDIO!" == "true" (
    set "WORLD_AUDIO_OPTS=-an"
) else (
    set "WORLD_AUDIO_OPTS=-map 0:a? -c:a copy"
)
"%FFMPEG_EXE%" -color_range 1 -colorspace 1 -color_primaries 1 -i "%INPUT_FILE%" -y -filter_complex "[0:v]crop=!WORLD_CROP![world];[0:v]crop=!DEPTH_CROP![depth]" ^
 -map "[world]" !WORLD_AUDIO_OPTS! !WORLD_VIDEO_OPTS! "%OUTPUT_WORLD%" ^
 -map "[depth]" -an !DEPTH_VIDEO_OPTS! "%OUTPUT_DEPTH%"
set "FFMPEG_ERRORLEVEL=!errorlevel!"
if !FFMPEG_ERRORLEVEL! equ 0 (
    if not exist "%OUTPUT_WORLD%" (
        set "FFMPEG_ERRORLEVEL=9009"
    ) else if not exist "%OUTPUT_DEPTH%" (
        set "FFMPEG_ERRORLEVEL=9009"
    )
)
exit /b !FFMPEG_ERRORLEVEL!