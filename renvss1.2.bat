@echo off
rem RenVSS 1.2
rem Modified by TheLANRanger
rem We are redirecting the output of the commands and any errors to NUL. 
rem If you would like to see the output, then remove the  2>NUL from the end of the commands.

rem ------------------------
rem Check if the script was started with Administrator privileges.
rem Method from http://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights
rem ------------------------
net session >nul 2>&1

if %errorLevel% NEQ 0 (
 echo.
 echo You do not have the required Administrator privileges.
 echo Please run the script again as an Administrator.
 echo.
 echo Script Aborting!
 PAUSE
 goto END
)
rem ------------------------

rem ------------------------
rem Enable Registry Backup (Disabled post 10 1803)
rem ------------------------
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Configuration Manager" /v EnablePeriodicBackup /t REG_DWORD /d 00000001 /f
rem ------------------------

rem-------------------------
rem Enable Volume Shadow Copy for local Disks and create schedule tasks
rem NOTE: There must be a VSS-Task-Disk task for partition (drive letter) on your system! Modify accordingly!
rem ------------------------
sc config vss start= auto
sc start vss

SCHTASKS /Create /SC DAILY /TN VSS-Task-Daily /RL HIGHEST /TR "%WinDir%\System32\wbem\WMIC.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint \"SystemRestore-^%Date^%\", 100, 7 " /ST 22:00 /F
SCHTASKS /Create /SC DAILY /TN VSS-Task-Disk-C /RL HIGHEST /TR "%WinDir%\System32\wbem\WMIC.exe shadowcopy call create Volume=""C:\\""" /ST 22:00 /F
rem SCHTASKS /Create /SC DAILY /TN VSS-Task-Disk-D /RL HIGHEST /TR "%WinDir%\System32\wbem\WMIC.exe shadowcopy call create Volume=""D:\\""" /ST 22:00 /F

schtasks /RUN /TN VSS-Task-Daily
schtasks /RUN /TN VSS-Task-Disk-C
rem schtasks /RUN /TN VSS-Task-Disk-D
rem-------------------------

rem ------------------------
rem Rename vssadmin.exe to help prevent malware from deleting shadow copies.
rem Code modified but mostly courtesy of bleepingcomputer.com
rem ------------------------
if NOT exist %WinDir%\system32\vssadmin.exe  (
 if NOT exist %WinDir%\SysWOW64\vssadmin.exe  (
  echo.
  echo. %WinDir%\system32\vssadmin.exe does not exist!
  echo  Script Aborting!
  PAUSE
  goto skipvss
 )
)

rem We need to give the Administrators ownership before we can change permissions on the file
takeown /F %WinDir%\system32\vssadmin.exe /A >nul 2>&1
takeown /F %WinDir%\SysWOW64\vssadmin.exe /A >nul 2>&1

rem Give Administrators the Change permissions for the file
CACLS %WinDir%\system32\vssadmin.exe /E /G "Administrators":C >nul 2>&1
CACLS %WinDir%\SysWOW64\vssadmin.exe /E /G "Administrators":C >nul 2>&1

rem Generate the name we are going to use when rename vssadmin.exe
rem This filename will be based off of the date and time.
rem http://blogs.msdn.com/b/myocom/archive/2005/06/03/so-what-the-heck-just-happened-there.aspx
for /f "delims=/ tokens=1-3" %%a in ("%DATE:~4%") do (
    for /f "delims=:. tokens=1-4" %%m in ("%TIME: =0%") do (
        set RenFile=vssadmin.exe-%%c-%%b-%%a-%%m%%n%%o%%p
    )
)

rem Rename vssadmin.exe to the filename in the RenFile variable
ren %WinDir%\system32\vssadmin.exe %RenFile% >nul 2>&1
ren %WinDir%\SysWOW64\vssadmin.exe %RenFile% >nul 2>&1

rem Check if the task was completed successfully 
if exist %WinDir%\system32\%RenFile% (
 echo.
 echo vssadmin.exe has been successfully renamed 
 echo to %WinDir%\system32\%RenFile%.
 pause
) else (
 echo.
 echo There was a problem renaming vssadmin.exe
 echo to %WinDir%\system32\%RenFile%.
 echo.
 pause
)
if exist %WinDir%\SysWOW64\%RenFile% (
 echo.
 echo vssadmin.exe has been successfully renamed 
 echo to %WinDir%\SysWOW64\%RenFile%.
 pause
) else (
 echo.
 echo There was a problem renaming vssadmin.exe
 echo to %WinDir%\SysWOW64\%RenFile%.
 echo.
 pause
)

:skipvss
rem ------------------------



:END