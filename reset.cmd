@ECHO OFF
powershell -ExecutionPolicy ByPass -File %~dp0\migrate.ps1 1
PAUSE
