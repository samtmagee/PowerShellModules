# Author Matthew Carter
<#
.Synopsis
   A wrapper around Get-ADComputer.
.DESCRIPTION
   This cmdlet is a wrapper around Get-ADComputer which helps get rooms of computers at a time.
.EXAMPLE
   Get-RegexADComputer -Regex 'CN=3020-..,'
.EXAMPLE
   Get-RegexADComputer -Regex 'OU=208,','OU=209,','OU=210,'
#>
function Get-RegexADComputer
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [string[]]
        $Regex
    )

    Begin
    {
        Import-Module ActiveDirectory
    }
    Process
    {
        Get-ADComputer -Filter '*' -Properties '*' -SearchBase 'OU=Other,OU=Workstations,DC=isleworthsyon,DC=local' | Where-Object {
            $dn = $_.distinguishedName;
            ($Regex | Where-Object {$dn -match "$_"} ).Count -gt 0
        }
    }
    End
    {
    }
}