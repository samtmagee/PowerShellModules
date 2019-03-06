<#
.Synopsis
   Change Windows product key on remote computer
.DESCRIPTION
   Long description
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
        [Parameter]
        $ComputerName="localhost",

        # ProductKey
        [Parameter(Mandatory=$true)]
        $ProductKey
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock { slmgr -ipk $ProductKey }
}
