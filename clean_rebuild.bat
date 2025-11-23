@echo off
:: ==================================================
:: Workroo App — Flutter Clean & Rebuild Script
:: Author: ChatGPT (custom project setup)
:: ==================================================

echo.
echo 🔧 [1/5] Cleaning old Flutter build files...
flutter clean
if %errorlevel% neq 0 goto error

echo.
echo 📦 [2/5] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 goto error

echo.
echo 🧰 [3/5] Repairing pub cache (may take a minute)...
flutter pub cache repair
if %errorlevel% neq 0 goto error

echo.
echo 🚀 [4/5] Running fresh build (Chrome default)...
flutter run -d chrome --web-renderer html --web-browser-flag "--disable-cache"
if %errorlevel% neq 0 goto error

echo.
echo ✅ Rebuild complete! App should now be running successfully.
pause
exit /b 0

:error
echo ❌ An error occurred during the process. Please check your Flutter installation or environment.
pause
exit /b 1
