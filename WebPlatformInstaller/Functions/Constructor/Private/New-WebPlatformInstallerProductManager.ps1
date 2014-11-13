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