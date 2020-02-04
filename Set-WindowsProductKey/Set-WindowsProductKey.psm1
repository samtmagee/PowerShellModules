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
        [string[]]$ComputerName=$null,

        # ProductKey
        [Parameter(Mandatory=$true)]
        [string]$ProductKey,

        [Parameter(Mandatory=$false)]
        [pscredential]$Credential=$null
    )

    # Check the product key is in a valid format
    if ($ProductKey -notmatch '^([a-zA-Z0-9]{5})-([a-zA-Z0-9]{5})-([a-zA-Z0-9]{5})-([a-zA-Z0-9]{5})-([a-zA-Z0-9]{5})$') {
        Write-Error -Message 'The product key was not in the form XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
        return
    }

    if ($Credential) {
        $session = New-CimSession -ComputerName $ComputerName -Credential $Credential
    } else {
        $session = New-CimSession -ComputerName $ComputerName
    }
    
    $SLS = Get-CimInstance -CimSession $session -ClassName 'SoftwareLicensingService'
    $SLS | Invoke-CimMethod -CimSession $session -MethodName 'InstallProductKey' -Arguments @{ProductKey=$ProductKey}
    $SLS | Invoke-CimMethod -CimSession $session -MethodName 'RefreshLicenseStatus';
};
