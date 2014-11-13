#Requires -Version 3.0

<#
.Synopsis
   Edit Config in Console
.DESCRIPTION
   Read config and edit in the console
.EXAMPLE
   Edit-WebPlatformInstallerConfig
#>
function Edit-WebPlatformInstallerConfig
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
        if ($NoProfile)
        {
            PowerShell_ise.exe -File $configPath -NoProfile
        }
        else
        {
            PowerShell_ise.exe -File $configPath
        }
    }
    else
    {
        ("Could not found configuration file '{0}'." -f $configPath) | Write-ValentiaVerboseDebug
    }

}
