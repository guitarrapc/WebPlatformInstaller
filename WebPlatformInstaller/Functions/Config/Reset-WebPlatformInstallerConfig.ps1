#Requires -Version 3.0

<#
.Synopsis
   Edit Config in Console
.DESCRIPTION
   Read config and edit in the console
.EXAMPLE
   Edit-WebPlatformInstallerConfig
#>
function Reset-WebPlatformInstallerConfig
{
    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [string]$configPath = (Join-Path $WebPlatformInstaller.appdataconfig.root $WebPlatformInstaller.appdataconfig.file),

        [parameter(mandatory = 0, position = 1)]
        [switch]$NoProfile
    )

    if (Test-Path $configPath)
    {
        . $configPath
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }

}
