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