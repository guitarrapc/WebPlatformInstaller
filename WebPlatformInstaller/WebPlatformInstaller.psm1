#region Initializer

function New-WebPlatformInstaller
{
    [OutputType([Void])] 
    [CmdletBinding()]
    param()

    if (-not(Test-Path $WebPlatformInstaller.RequiredAssemblies)){ throw New-Object System.IO.FileNotFoundException ("Unable to find the specified file.", $WebPlatformInstaller.RequiredAssemblies) }
    if (-not(Test-Path $WebPlatformInstaller.Requiredexe)){ throw New-Object System.IO.FileNotFoundException ("Unable to find the specified file.", $WebPlatformInstaller.Requiredexe) }

    try
    {
        [reflection.assembly]::LoadWithPartialName("Microsoft.Web.PlatformInstaller") > $null
        Add-Type -Path $WebPlatformInstaller.RequiredAssemblies
    }
    catch
    {
    }
}

#endregion

#region Private Module to load default configuration

function Import-WebPlatformInstaller
{

    [CmdletBinding()]
    param
    (
        [string]$OriginalConfigFilePath = (Join-Path $WebPlatformInstaller.originalconfig.root $WebPlatformInstaller.originalconfig.file),
        [string]$NewConfigFilePath = (Join-Path $WebPlatformInstaller.appdataconfig.root $WebPlatformInstaller.appdataconfig.file)
    )

    # Installation time will call here
    if (Test-Path $OriginalConfigFilePath -pathType Leaf)
    {
        try 
        {        
            Write-Verbose "Load Current Configuration or Default."
            . $OriginalConfigFilePath
            return
        } 
        catch 
        {
            throw ('Error Loading Configuration from {0}: ' -f $OriginalConfigFilePath) + $_
        }
    }

    # Import time will call here
    if (Test-Path $NewConfigFilePath -pathType Leaf) 
    {
        try 
        {        
            Write-Verbose "Load Current Configuration or Default."
            . $NewConfigFilePath
            return
        } 
        catch 
        {
            throw ('Error Loading Configuration from {0}: ' -f $NewConfigFilePath) + $_
        }
    }
}

#endregion

# contains default base configuration, may not be override without version update.
$Script:WebPlatformInstaller = [ordered]@{}
$WebPlatformInstaller.Name = "WebPlatformInstaller"
$WebPlatformInstaller.modulePath = Split-Path -parent $MyInvocation.MyCommand.Definition
$WebPlatformInstaller.helpersPath = "\functions"
$WebPlatformInstaller.combineTempfunction = '{0}.ps1' -f $WebPlatformInstaller.name
$WebPlatformInstaller.fileEncode = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]'utf8'
$WebPlatformInstaller.context = New-Object System.Collections.Stack # holds onto the current state of all variables

# contains PS Build-in Preference status
$WebPlatformInstaller.preference = [ordered]@{
    ErrorActionPreference = @{
        original = $ErrorActionPreference
        custom   = 'Stop'
    }
    DebugPreference       = @{
        original = $DebugPreference
        custom   = 'SilentlyContinue'
    }
    VerbosePreference     = @{
        original = $VerbosePreference
        custom   = 'SilentlyContinue'
    }
    ProgressPreference = @{
        original = $ProgressPreference
        custom   = 'SilentlyContinue'
    }
}

# contains default configuration path
$WebPlatformInstaller.originalconfig = [ordered]@{
    root     = Join-Path $WebPlatformInstaller.modulePath '\config'
    file     = '{0}-config.ps1' -f $WebPlatformInstaller.name         # default configuration file name to read
}

$WebPlatformInstaller.appdataconfig = [ordered]@{
    root     = Join-Path $env:APPDATA $WebPlatformInstaller.name      # default configuration path
    file     = '{0}-config.ps1' -f $WebPlatformInstaller.name         # default configuration file name to read
}
$WebPlatformInstaller.appdataconfig.backup = Join-Path $WebPlatformInstaller.appdataconfig.root '\config'

#-- Public Loading Module Parameters (Recommend to use ($WebPlatformInstaller.defaultconfigurationfile) for customization)--#

$WebPlatformInstaller.RequiredAssemblies = 'C:\Program Files\Microsoft\Web Platform Installer\Microsoft.Web.PlatformInstaller.dll'
$WebPlatformInstaller.Requiredexe = 'C:\Program Files\Microsoft\Web Platform Installer\WebpiCmd-x64.exe'

# -- Import Default configuration file -- #
Import-WebPlatformInstaller

# -- Initializer -- #
New-WebPlatformInstaller

# -- Export Modules when loading this module -- #

$outputPath = Join-Path $WebPlatformInstaller.modulePath $WebPlatformInstaller.combineTempfunction
if (Test-Path $outputPath){ . $outputPath }

#-- Export Modules when loading this module --#
# You can check with following Command
# Import-Module PSChatwork -Verbose -Force; $WebPlatformInstaller

Export-ModuleMember `
    -Function `
        * `
    -Variable `
        * `
    -Alias *