WebPlatformInstaller
==========

WebPlatformInstaller Module will manage your installation through WebPI.

Requirement
----

Make sure you have installed [Microsoft Web Platform Installer](http://www.microsoft.com/web/downloads/platform.aspx) in advanced.

If you are using PowerShell v4 or above, I prepare DSC Configuration to install WebPI for you.

You may find ```Tools\Install-WebplatformInstaller```, and just run it to install WebPI. 

Installation
----

Run following command at CMD.exe or PowerShell.

||
|----|
|powershell -NoProfile -ExecutionPolicy unrestricted -Command 'iex ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((irm "https://api.github.com/repos/guitarrapc/WebPlatformInstaller/contents/WebPlatformInstaller/Tools/RemoteInstall.ps1").Content))).Remove(0,1)'|


Import Module
----

Recommend to open Elevated PowerShell.exe

```Powershell
Import-Module WebPlatformInstaller
```

Download 

# Functions

You can check what kind of functions included in module.

```Powershell
Get-Command -Module WebPlatformInstaller
```

Here's Cmdlets use in public

|CommandType|Name|Version|Source
----|----|----|----
Function|Backup-WebPlatformInstallerConfig       |    1.0.0    |WebPlatformInstaller
Function|Edit-WebPlatformInstallerConfig            | 1.0.0        | WebPlatformInstaller
Function|Get-WebPlatformInstallerProduct           |  1.0.0       | WebPlatformInstaller
Function|Install-WebPlatformInstallerProgram      |   1.0.0     | WebPlatformInstaller
Function|Reset-WebPlatformInstallerConfig          |  1.0.0      | WebPlatformInstaller
Function|Show-WebPlatformInstallerConfig          |   1.0.0     | WebPlatformInstaller
Function|Test-WebPlatformInstallerProductIsInstalled |1.0.0 |  WebPlatformInstaller