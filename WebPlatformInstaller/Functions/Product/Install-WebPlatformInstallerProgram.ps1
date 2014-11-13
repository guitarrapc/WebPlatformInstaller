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
                        $psi.Verb = "runas"

                        $process = New-Object System.Diagnostics.Process 
                        $process.StartInfo = $psi
                        $process.Start() > $null
                        $process.WaitForExit()
                        $output = $process.StandardOutput.ReadToEnd()
                        $process.StandardOutput.ReadLine()
                    
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