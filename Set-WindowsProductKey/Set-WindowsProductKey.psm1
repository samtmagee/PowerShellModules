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
        [string[]]$ComputerName="localhost",

        # ProductKey
        [Parameter(Mandatory=$true)]
        [string]$ProductKey
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {

        $service = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingService";
        $service.InstallProductKey($using:ProductKey) | Out-Null;
        $service.RefreshLicenseStatus() | Out-Null;
        
        Start-Sleep -Seconds 5;
        
        $edition = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID;

        return [pscustomobject]@{"ComputerName"=$env:computername; "Edition"=$edition;};
    }
}
