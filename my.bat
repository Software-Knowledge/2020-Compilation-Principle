@echo off
set date=%DATE%
set time=%TIME%
for /f "delims=" %%i in ("%cd%") do set folder=%%~ni

git add .
git commit -m "%folder% update at %date%"
git push
echo finish