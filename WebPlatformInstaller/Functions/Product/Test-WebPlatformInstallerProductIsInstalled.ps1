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

