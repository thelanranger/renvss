#### ========================
#### Check if the script was started with Administrator privileges.
#### ------------------------
#Requires -RunAsAdministrator
#### ========================

#### Format date for file rename
$date = Get-Date -format "yyyyMMdd"


if (Test-Path $env:windir\system32\vssadmin.exe)  {
  #### We need to give the Administrators ownership before we can change permissions on the file
  takeown /F $env:windir\system32\vssadmin.exe /A
  #### Give Administrators the Change permissions for the file
  icacls $env:windir\system32\vssadmin.exe /grant Administrators:F
  #### Rename vssadmin.exe to the filename in the RenFile variable
  ren $env:windir\system32\vssadmin.exe $env:windir\system32\vssadmin.exe-$date

  #### Check rename:
     if (Test-Path $env:windir\system32\vssadmin.exe-$date) {
      echo "system32\vssadmin.exe has been successfully renamed"
      echo "to $env:windir\system32\vssadmin.exe-$date."
     }
}


if (Test-Path $env:windir\SysWOW64\vssadmin.exe)  {
  #### We need to give the Administrators ownership before we can change permissions on the file
  takeown /F $env:windir\SysWOW64\vssadmin.exe /A
  #### Give Administrators the Change permissions for the file
  icacls $env:windir\SysWOW64\vssadmin.exe /grant Administrators:F
  #### Rename vssadmin.exe to the filename in the RenFile variable
  ren $env:windir\SysWOW64\vssadmin.exe $env:windir\SysWOW64\vssadmin.exe-$date

  #### Check rename:
     if (Test-Path $env:windir\SysWOW64\vssadmin.exe-$date) {
      echo "SysWOW64\vssadmin.exe has been successfully renamed "
      echo "to $env:windir\SysWOW64\vssadmin.exe-$date."
     } 
}