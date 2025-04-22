@echo off
setlocal enabledelayedexpansion

:: Root directory
set ROOT_DIR=%CD%
set BUILD_DIR=%ROOT_DIR%\build
set INSTALL_DIR=%ROOT_DIR%\install

:: Create directories
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %INSTALL_DIR% mkdir %INSTALL_DIR%

:: Function to build for a specific platform and architecture
call :build_platform "windows-x64" "-A x64"
call :build_platform "windows-x86" "-A Win32"

:: If Visual Studio supports ARM64, build for ARM64
where /q cl.exe
if %ERRORLEVEL% == 0 (
    cl.exe /? 2>&1 | findstr /C:"ARM64" > nul
    if !ERRORLEVEL! == 0 (
        call :build_platform "windows-arm64" "-A ARM64"
    )
)

echo All builds completed successfully!
echo Libraries are in %INSTALL_DIR%\^<platform^>\lib
echo Headers are in %INSTALL_DIR%\^<platform^>\include

goto :eof

:build_platform
set platform=%~1
set cmake_options=%~2
set build_subdir=%BUILD_DIR%\%platform%
set install_subdir=%INSTALL_DIR%\%platform%

echo ===== Building for %platform% =====
if not exist "%build_subdir%" mkdir "%build_subdir%"
if not exist "%install_subdir%" mkdir "%install_subdir%"

cd "%build_subdir%"
cmake %cmake_options% -DBUILD_SHARED_LIBS=ON -DBUILD_WINDOWS=ON -DCMAKE_INSTALL_PREFIX="%install_subdir%" "%ROOT_DIR%"
cmake --build . --config Release
cmake --install . --config Release

echo ===== Completed %platform% build =====
echo.

cd "%ROOT_DIR%"
exit /b 0 