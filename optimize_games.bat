@echo off
TITLE Game JSON Optimizer

:: Folder mein switch karein
cd /d "%~dp0"

:: Sahi file name yahan likhein
powershell.exe -ExecutionPolicy Bypass -File "UpdateGameList - Copy.ps1"

pause