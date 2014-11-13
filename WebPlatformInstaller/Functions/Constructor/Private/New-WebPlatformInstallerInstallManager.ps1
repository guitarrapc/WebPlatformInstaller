#region Constructor

function New-WebPlatformInstallerInstallManager
{
    [OutputType([Void])]
    [CmdletBinding()]
    param()

    $WebPlatformInstaller.installManager = New-Object Microsoft.Web.PlatformInstaller.InstallManager
}

#endregion