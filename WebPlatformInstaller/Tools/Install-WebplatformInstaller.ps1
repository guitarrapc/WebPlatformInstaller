#Requires -Version 4.0
#Requires -RunAsAdministrator

Configuration InstallWPIlauncher
{
    function Get-RedirectedUrl ([String]$URL)
    { 
        $request = [System.Net.WebRequest]::Create($url)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $response | where StatusCode -eq "Found" | % {$_.GetResponseHeader("Location")}
    }

    $name = "Web Platform Installer"
    $DownloadPath = Get-RedirectedUrl "http://go.microsoft.com/fwlink/?LinkId=255386"
    $productId = "4D84C195-86F0-4B34-8FDE-4A17EB41306A" # onceInstall and search from Reg by Get-DSCModuleProductId

    Package WebPI
    {
        Name       = $name
        Path       = $DownloadPath
        ReturnCode = 0
        ProductId  = $productId
    }
}

$path = "$env:USERPROFILE\Desktop\InstallWPIlauncher"
InstallWPIlauncher -OutputPath $path
Start-DSCConfiguration -Path $path -Wait -Force -Verbose