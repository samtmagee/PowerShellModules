<#
.Synopsis
   Set the Windows product key.
.DESCRIPTION
   Set the Windows product key on a local or remote computer.
.EXAMPLE
   Set-WindowsProductKey -ProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
   This will set the local machines product key.
.EXAMPLE
   Set-WindowsProductKey -ComputerName "bob-desktop" -ProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
   This will set the product key on the computer bob-desktop.
#>
function Set-WindowsProductKey
{
    [CmdletBinding()]
    Param
    (
        # ComputerName
        [string[]]$ComputerName="$env:computername",

        # ProductKey
        [Parameter(Mandatory=$true)]
        [string]$ProductKey
    )

    $service = Get-WmiObject -Query "select * from SoftwareLicensingService" -ComputerName $ComputerName
    $service.InstallProductKey($ProductKey)
    $service.RefreshLicenseStatus()
}
