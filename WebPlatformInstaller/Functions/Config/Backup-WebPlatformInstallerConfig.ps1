#requires -Version 3.0

function Backup-WebPlatformInstallerConfig
{
<#
.Synopsis
   Backup CurrentConfiguration with timestamp.
.DESCRIPTION
   Backup configuration in $WebPlatformInstaller.appdataconfig.root
.EXAMPLE
   Backup-WebPlatformInstallerConfig
#>

    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [System.String]$configPath = (Join-Path $WebPlatformInstaller.appdataconfig.root $WebPlatformInstaller.appdataconfig.file),

        [parameter(mandatory = 0, position = 1)]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding = $WebPlatformInstaller.fileEncode
    )

    if (Test-Path $configPath)
    {
        $private:datePrefix = ([System.DateTime]::Now).ToString($WebPlatformInstaller.log.dateformat)
        $private:backupConfigName = $datePrefix + "_" + $WebPlatformInstaller.appdataconfig.file
        $private:backupConfigPath = Join-Path $WebPlatformInstaller.appdataconfig.root $backupConfigName

        Write-Verbose ("Backing up config file '{0}' => '{1}'." -f $configPath, $backupConfigPath)
        Get-Content -Path $configPath -Encoding $encoding -Raw | Out-File -FilePath $backupConfigPath -Encoding $encoding -Force 
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }
}
