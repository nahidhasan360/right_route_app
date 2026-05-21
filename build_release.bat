@echo off
echo ========================================
echo  Right Routes - Release Build Script
echo ========================================
echo.

echo [1/5] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo.
echo [2/5] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo [3/5] Analyzing code...
call flutter analyze --no-fatal-infos
if %errorlevel% neq 0 (
    echo WARNING: Code analysis found issues (continuing anyway)
)

echo.
echo [4/5] Building release APK...
echo This may take several minutes...
call flutter build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    echo.
    echo Troubleshooting tips:
    echo - Check if you have enough RAM (at least 4GB free)
    echo - Close other applications to free up memory
    echo - Try running: flutter clean then flutter pub get
    echo - Check android\gradle.properties for memory settings
    pause
    exit /b 1
)

echo.
echo [5/5] Build completed successfully!
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
