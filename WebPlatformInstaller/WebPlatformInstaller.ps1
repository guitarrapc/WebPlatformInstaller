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

# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Config\Backup-WebPlatformInstallerConfig.ps1

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
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }

}

# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Config\Edit-WebPlatformInstallerConfig.ps1

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

# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Config\Reset-WebPlatformInstallerConfig.ps1

#Requires -Version 3.0

<#
.Synopsis
   Show Config in Console
.DESCRIPTION
   Read config and show in the console
.EXAMPLE
   Show-WebPlatformInstallerConfig
#>
function Show-WebPlatformInstallerConfig
{
    [CmdletBinding()]
    param
    (
        [parameter(mandatory = 0, position = 0)]
        [string]$configPath = (Join-Path $WebPlatformInstaller.appdataconfig.root $WebPlatformInstaller.appdataconfig.file),

        [parameter(mandatory = 0, position = 1)]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding = "default"
    )

    if (Test-Path $configPath)
    {
        Get-Content -Path $configPath -Encoding $encoding
    }
    else
    {
        Write-Verbose ("Could not found configuration file '{0}'." -f $configPath)
    }
}

# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Config\Show-WebPlatformInstallerConfig.ps1

#region Constructor

function New-WebPlatformInstallerInstallManager
{
    [OutputType([Void])]
    [CmdletBinding()]
    param()

    $WebPlatformInstaller.installManager = New-Object Microsoft.Web.PlatformInstaller.InstallManager
}

#endregion
# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Constructor\Private\New-WebPlatformInstallerInstallManager.ps1

#region Constructor

function New-WebPlatformInstallerProductManager
{
    [OutputType([Void])] 
    [CmdletBinding()]
    param()

    $productManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager
    $productManager.Load()
    $WebPlatformInstaller.productManager = $productManager
    
    Write-Verbose "Remove Blank Keywords Products"
    $WebPlatformInstaller.productManagerProducts = $WebPlatformInstaller.productManager.Products | where Keywords
    $WebPlatformInstaller.productManagerProductsBlankKeyword = $WebPlatformInstaller.productManager.Products | where {$_.Keywords.Name -eq $null}
}

#endregion
# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Constructor\Private\New-WebPlatformInstallerProductManager.ps1

#region Product

function Get-WebPlatformInstallerProduct
{
<#
.Synopsis
   Get WebPlatformInstaller Packages.
.DESCRIPTION
   This function will return Product information for WebPlatform Installer.
   You can select 2 mode.
   1. -ProductId will give you availability to filter package.
   2. Omit -ProductId will return all packages.
   
   Make sure No keyword items and IIS Components (Windows Feature) will never checked.
.EXAMPLE
   Get-WebPlatformInstallerProduct
   # Returns All Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -Installed
   # Returns All Installed Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -Available
   # Returns All Available Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy
   # Returns WDeploy Product information
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy -Installed
   # Returns WDeploy Product information if installed
.EXAMPLE
   Get-WebPlatformInstallerProduct -ProductId WDeploy -Available
   # Returns WDeploy Product information if available
#>
    [OutputType([Microsoft.Web.PlatformInstaller.Product[]])] 
    [CmdletBinding(DefaultParameterSetName = "Any")]
    param
    (
        [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId,
        
        [parameter(Mandatory = 0, Position = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Installed")]
        [switch]$Installed,
        
        [parameter(Mandatory = 0, Position = 1, ValueFromPipelineByPropertyName = 1, ParameterSetName = "Available")]
        [switch]$Available,

        [switch]$Force
    )

    begin
    {
        if (($null -eq $WebPlatformInstaller.productManagerProducts) -or $Force){ New-WebPlatformInstallerProductManager }

        # Initialize
        if ($PSBoundParameters.ContainsKey('ProductId'))
        {
            $result = $null
            $private:productManagerDic = New-Object 'System.Collections.Generic.Dictionary[[string], [Microsoft.Web.PlatformInstaller.Product]]' ([StringComparer]::OrdinalIgnoreCase)
            $private:productManagerList = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Product]'
            $WebPlatformInstaller.productManagerProducts | %{$productManagerDic.Add($_.ProductId, $_)}
        }
    }

    process
    {
        if (-not $PSBoundParameters.ContainsKey('ProductId'))
        {
            Write-Verbose ("Searching All Products.")
            switch ($true)
            {
                $Installed { return $WebPlatformInstaller.productManagerProducts | where {$_.IsInstalled($false) } | sort ProductId }
                $Available { return $WebPlatformInstaller.productManagerProducts | where {-not $_.IsInstalled($false) } | sort ProductId }
                Default { return $WebPlatformInstaller.productManagerProducts | sort ProductId }
            }
        }

        foreach ($id in $ProductId)
        {
            # Search product by ProductId
            Write-Verbose ("Searching ProductId : '{0}'" -f $id)
            $isSuccess = $productManagerDic.TryGetValue($id, [ref]$result)

            # Success
            if ($isSuccess){ $productManagerList.Add($result); continue; }

            # Skip
            if ($id -in $WebPlatformInstaller.productManagerProductsBlankKeyword.ProductId){ [Console]::WriteLine("ProductId '{0}' will skip as it is not supported." -f $id); continue; }

            # Fail
            throw New-Object System.InvalidOperationException ("WebPlatform Installation could not found package '{0}' as valid ProductId. Please select from '{1}'" -f $id, (($WebPlatformInstaller.productManagerProducts.ProductId | sort) -join "', '"))
        }

        switch ($true)
        {
            $Installed { return $productManagerList | where {$_.IsInstalled($false) } | sort ProductId }
            $Available { return $productManagerList | where {-not $_.IsInstalled($false) } | sort ProductId }
            Default { return $productManagerList | sort ProductId }
        }
    }
}

#endregion
# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Product\Get-WebPlatformInstallerProduct.ps1

#region Product

function Install-WebPlatformInstallerProgram
{
<#
.Synopsis
   Install target Package.
.DESCRIPTION
   This function will install desired Package.
   If Package is already installed, then skip it.
.EXAMPLE
   Install-WebPlatformInstallerProgram -ProductId WDeploy
   # Install WDeploy
#>

    [OutputType([void])] 
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId,

        [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
        [ValidateSet('en', 'fr', 'es', 'de', 'it', 'ja', 'ko', 'ru', 'zh-cn', 'zh-tw', 'cs', 'pl', 'tr', 'pt-br', 'he', 'zh-hk', 'pt-pt')]
        [string]$LanguageCode = 'en'
    )

    process
    {
        Write-Verbose "Checking Product is already installed."
        $ProductId `
        | % {
            if(Test-WebPlatformInstallerProductIsInstalled -ProductId $_){ [Console]::WriteLine("Package '{0}' already installed. Skip installation." -f $_); return; }
            $productIdList.Add($_)
        }
    }

    end
    {
        if (($productIdList | measure).count -eq 0){ return; }
        try
        {
            # Prerequisites
            Write-Verbose "Get Product"
            [Microsoft.Web.PlatformInstaller.Product[]]$product = Get-WebPlatformInstallerProduct -ProductId $productIdList
            if ($null -eq $product){ throw New-Object System.NullReferenceException }

            # Install
            # InstallByNET -LanguageCode $LanguageCode -product $product
            InstallByWebPICmd -Name $ProductId
        }
        catch
        {
            throw $_
        }
        finally
        {
            if ($null -ne $WebPlatformInstaller.installManager){ $WebPlatformInstaller.installManager.Dispose() }
        }
    }

    begin
    {
        # Initialize
        if ($null -eq $WebPlatformInstaller.productManager){ New-WebPlatformInstallerProductManager }
        $productIdList = New-Object 'System.Collections.Generic.List[string]'

        function ShowInstallerContextStatus
        {
            if ($null -ne $WebPlatformInstaller.installManager.InstallerContexts){ $WebPlatformInstaller.installManager.InstallerContexts | Out-String -Stream | Write-Verbose }
        }

        function WatchInstallationStatus
        {
            [OutputType([bool])] 
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [string]$ProductId,

                [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.InstallationState]$PreStatus,

                [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.InstallationState]$PostStatus
            )

            # Skip
            if ($postStatus -eq $preStatus)
            {
                Write-Verbose "Installation not begin"
                return $false
            }

            # Monitor
            ShowInstallerContextStatus
            while($postStatus -ne [Microsoft.Web.PlatformInstaller.InstallationState]::InstallCompleted)
            {
                Start-Sleep -Milliseconds 100
                $postStatus = $WebPlatformInstaller.installManager.InstallerContexts.InstallationState
            }
            ShowInstallerContextStatus
            $logfiles = $WebPlatformInstaller.installManager.InstallerContexts.Installer.LogFiles
            $latestLog = ($logfiles | select -Last 1)
            [Console]::WriteLine(("'{0}' Installation completed. Check Log file at '{1}'" -f ($ProductId -join "', '"), $latestLog))
            Write-Verbose ("Latest Log file is '{0}'." -f (Get-Content -Path $latestLog -Encoding UTF8 -Raw))
            return $true
        }

        function InstallByNET
        {
            [OutputType([void])] 
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [string]$LanguageCode,

                [parameter(Mandatory = 0, Position = 0, ValueFromPipelineByPropertyName = 1)]
                [Microsoft.Web.PlatformInstaller.Product[]]$product
            )

            # Initialize
            New-WebPlatformInstallerInstallManager
            $installer = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Installer]'

            # Get Language
            [Microsoft.Web.PlatformInstaller.Language]$language = $WebPlatformInstaller.productManager.GetLanguage($LanguageCode)        

            $product `
            | % {
                Write-Verbose "Get Installer"
                $x = $_.GetInstaller($language)
                if ($null -eq $x.InstallerFile){ [Console]::WriteLine("Package '{0}' detected as no Installer to install. Skip Installation." -f $_.ProductId); return; }
                $installer.Add($x)
                $WebPlatformInstaller.InstallManager.Load($installer)
 
                Write-Verbose "Donwload Installer"
                ShowInstallerContextStatus
                $failureReason = $null
                $success = $WebPlatformInstaller.InstallManager.InstallerContexts | %{ $WebPlatformInstaller.installManager.DownloadInstallerFile($_, [ref]$failureReason) }
                if ((-not $success) -and $failureReason){ throw New-Object System.InvalidOperationException ("Donwloading '{0}' Failed Exception!! Reason : {1}" -f ($ProductId -join "' ,'"), $failureReason ) }
            
                Write-Verbose "Show Donwloaded Installer Status"
                ShowInstallerContextStatus

                # Get Status
                [Microsoft.Web.PlatformInstaller.InstallationState]$preStatus = $WebPlatformInstaller.installManager.InstallerContexts.InstallationState

                Write-Verbose "Start Installation with StartInstallation()"
                $WebPlatformInstaller.installManager.StartInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }

                Write-Verbose "Start Installation with StartApplicationInstallation()"
                $WebPlatformInstaller.installManager.StartApplicationInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }

                Write-Verbose "Start Installation with StartSynchronousInstallation()"
                $installResult = $WebPlatformInstaller.installManager.StartSynchronousInstallation()
                if (WatchInstallationStatus -ProductId $_.ProductId -PreStatus $preStatus -PostStatus $WebPlatformInstaller.installManager.InstallerContexts.InstallationState){ return; }
            }
        }

        function InstallByWebPICmd
        {
            [OutputType([Void])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [System.String[]]$Name
            )

            end
            {
                foreach ($x in $Name)
                {
                    Write-Verbose ("Installing package '{0}'" -f $x)
                    [string]$arguments = @(
                        "/Install",
                        "/Products:$x",
                        "/AcceptEula",
                        "/SuppressReboot"
                    )
                    Invoke-WebPICmd -Arguments $arguments
                }
            }

            begin
            {
                Write-Verbose "Start Installation with WebPICmd"
                function Invoke-WebPICmd
                {
                    [OutputType([System.String])]
                    [CmdletBinding()]
                    param
                    (
                        [parameter(Mandatory = $true)]
                        [System.String]$Arguments
                    )

                    $fileName  = $WebPlatformInstaller.Requiredexe
                    if (!(Test-Path -Path $fileName)){ throw New-Object System.InvalidOperationException ("Web Platform Installer not installed exception!") }

                    try
                    {
                        $psi = New-Object System.Diagnostics.ProcessStartInfo
                        $psi.CreateNoWindow = $true 
                        $psi.UseShellExecute = $false 
                        $psi.RedirectStandardOutput = $true
                        $psi.RedirectStandardError = $true
                        $psi.FileName = $fileName
                        $psi.Arguments = $Arguments

                        $process = New-Object System.Diagnostics.Process 
                        $process.StartInfo = $psi
                        $process.Start() > $null
                        $output = $process.StandardOutput.ReadToEnd()
                        $process.StandardOutput.ReadLine()
                        $process.WaitForExit() 
                    
                        return $output 
                    }
                    catch
                    {
                        $outputError = $process.StandardError.ReadToEnd()
                        throw $_ + $outputError
                    }
                    finally
                    {
                        if ($null -ne $psi){ $psi = $null}
                        if ($null -ne $process){ $process.Dispose() }
                    }
                }
            }
        }
    }
}

#endregion
# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Product\Install-WebPlatformInstallerProgram.ps1

#region Product

function Test-WebPlatformInstallerProductIsInstalled
{
<#
.Synopsis
   Test target Package is already installed or not.
.DESCRIPTION
   This function will check desired Package is already installed or not yet by Boolean.
   $true  : Means already installed.
   $false : Means not yet installed.
   Pass ProductId which you want to check.
.EXAMPLE
   Test-WebPlatformInstallerProductIsInstalled -ProductId WDeploy
   # Check WDeploy is installed or not.
#>
    [OutputType([bool])] 
    [CmdletBinding(DefaultParameterSetName = "Any")]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipelineByPropertyName = 1, ValueFromPipeline = 1)]
        [string[]]$ProductId
    )

    # Not use Cached Value
    $result = Get-WebPlatformInstallerProduct -ProductId $ProductId | % {$_.IsInstalled($false)}
    Write-Verbose $result
    return $result
}

#endregion


# file loaded from path : D:\GitHub\WebPlatformInstaller\WebPlatformInstaller\functions\Product\Test-WebPlatformInstallerProductIsInstalled.ps1

