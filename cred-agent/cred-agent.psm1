<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Load-Credential
{
    [CmdletBinding()]
    [OutputType([pscredential])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [System.String]
        $UserName,

        [System.String]
        $Path = "$env:APPDATA\password.xml"
    )

    [hashtable]$store = @{};
    try {
        [hashtable]$store = Import-Clixml -Path $Path -ErrorAction Stop;
    } catch {}
    return [pscredential]$store.Item($UserName);
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Store-Credential
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [pscredential]
        $Credential,

        [System.String]
        $Path = "$env:APPDATA\password.xml"
    )

    [hashtable]$store = @{};
    try {
        [hashtable]$store = Import-Clixml -Path $Path -ErrorAction Stop;
    } catch {}
    $store.Add($Credential.UserName, $Credential);
    Export-Clixml -Path $Path -InputObject $store;
}


<#
.Synopsis
   Unstore-Credential removes a credential from the credential store
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Unstore-Credential
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String]
        $UserName,

        [System.String]
        $Path = "$env:APPDATA\password.xml"
    )

    [hashtable]$store = Import-Clixml -Path $Path;
    $store.Remove($UserName);
    Export-Clixml -Path $Path -InputObject $store;
}


<#
.Synopsis
   Stores a credential for the current session only
.DESCRIPTION
   This cmdlet stores the credential in a global variable only for the current session.
   The first time it is run, it asks for the cred.
   On subsequent runs, it returns the credential that was saved on the first run.
   If the Update flag is used then the credential is prompted even if it was saved previously and the new credential is saved.
.EXAMPLE
   Cache-Credential -UserName 'user'
.EXAMPLE
    Cache-Credential -UserName 'user' -Update
#>
function Cache-Credential
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String]
        $UserName,

        [switch]
        $Update
    )

    if ($null -eq $Global:__mc_cred_cache) {
        $Global:__mc_cred_cache = @{};
    }

    if (-not $Update -and $Global:__mc_cred_cache.ContainsKey($UserName)) {
        return $Global:__mc_cred_cache.Item($UserName);
    } else {
        $c = Get-Credential $UserName;
        $Global:__mc_cred_cache.Item($UserName) = $c;
        return $c;
    }

}