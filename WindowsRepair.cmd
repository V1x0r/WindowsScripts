@echo off
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::

Title Roy's Windows Cleanup Script
echo ----------------------------------------------------------------
echo --                This will run various commands              --
echo --          When it is completed it will ask to restart       --
echo --        Look for any errors that occur in the sequence      --
echo ----------------------------------------------------------------
echo --                  Press [ENTER] to continue                 --
echo ----------------------------------------------------------------
pause
cls
echo ----------------------------------------------------------------
echo --      Running Dism /Online /Cleanup-Image /ScanHealth       --
echo ----------------------------------------------------------------
Dism /Online /Cleanup-Image /ScanHealth
echo
echo ----------------------------------------------------------------
echo -- Running Dism /Online /Cleanup-Image /AnalyzeComponentStore --
echo ----------------------------------------------------------------
Dism /Online /Cleanup-Image /AnalyzeComponentStore
echo
echo ----------------------------------------------------------------
echo --    Running Dism /Online /Cleanup-Image /RestoreHealth      --
echo ----------------------------------------------------------------
Dism /Online /Cleanup-Image /RestoreHealth
echo
echo ----------------------------------------------------------------
echo -- Running Dism /Online /Cleanup-Image /StartComponentCleanup --
echo ----------------------------------------------------------------
Dism /Online /Cleanup-Image /StartComponentCleanup
echo
echo ----------------------------------------------------------------
echo --Running Dism /Online /Cleanup-Image /RestoreHealth Once More--
echo ----------------------------------------------------------------
Dism /Online /Cleanup-Image /RestoreHealth
echo
echo ----------------------------------------------------------------
echo --                Running with SFC /Scannow                 --
echo ----------------------------------------------------------------
sfc /scannow
echo
echo ----------------------------------------------------------------
echo --   Now scheduling a Checkdisk to check and fix the system   --
echo --        you will have to select Y in order to schedule      --
echo ----------------------------------------------------------------
chkdsk C: /X /B /OfflineScanAndFix

echo ----------------------------------------------------------------
echo --       The cleanup process has completed successfully       --
echo ----------------------------------------------------------------
echo --            Press enter to restart the Computer             --
echo ----------------------------------------------------------------
pause
shutdown /r /t 00 /f
