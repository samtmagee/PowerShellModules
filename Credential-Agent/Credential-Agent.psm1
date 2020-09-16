<#
.SYNOPSIS
    Get-SavedCredential reads a pscredential from a file
.DESCRIPTION
    Use this cmdlet to retrieve a clixml encoded pscredential from a file.
    If not given a filename then this cmdlet looks in the following folders
    %APPDATA%\Credential-Agent
    %USERPROFILE%\Credential-Agent
    $XDG_CONFIG_HOME/Credential-Agent
    $HOME/Credential-Agent
    ./
    for the xml files
.PARAMETER UserName
    The username of the credential to retrieve.
    If a Path is given, then this parameter is ignored but still required.
.PARAMETER Path
    If this parameter is given then the UserName is ignored, no folder lookup is performed,
    and the credential is read from this file directly.
.EXAMPLE
    Set-SavedCredential -Credential (Get-Credential 'Administrator')

    This will prompt you to enter the password for the Administrator credential.
    It will save it into a file as described above.
    
    To get the credential back (or in another session)

    Get-SavedCredential -UserName 'Administrator'

    The UserName parameter corresponds to the UserName given by the Set-SavedCredential cmdlet
#>
function Get-SavedCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [System.String]
        $UserName,

        [System.String]
        $Path = $null
    )

    $Filename = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName))

    # If a path was not given
    if ([string]::IsNullOrEmpty($Path)) {

        # Try these environment variables, in order
        # Using the current directory '.' as a fallback
        foreach ($dir in @($env:APPDATA, $env:USERPROFILE, $env:XDG_CONFIG_HOME, $env:HOME, '.')) {
            # If the variable is set, use it as a prefix to the filename
            if ($dir.Length -gt 0) {
                $Path = "$($dir)/Credential-Agent/$($Filename).xml"
                # Stop after the first set variable
                break
            }
        }
    }

    # Import the xml file as a pscredential
    # If the file did not contain a pscredential then an error will be thrown to the caller
    [pscredential](Import-Clixml -LiteralPath $Path)
}


<#
.SYNOPSIS
    Set-SavedCredential writes a pscredential to a file
.DESCRIPTION
    Use this cmdlet to save a clixml encoded pscredential to a file.
    If not given a filename then this cmdlet looks in the following folders
    %APPDATA%\Credential-Agent\
    %USERPROFILE%\Credential-Agent\
    $XDG_CONFIG_HOME/Credential-Agent/
    $HOME/Credential-Agent/
    ./
    to save the file

    To get the pscredential back, use the Get-SavedCredential cmdlet and set the UserName parameter
    to the value of the Username of the pscredential object
.PARAMETER Credential
    A pscredential to save into the file
    The username form the pscredential is used to generate the filename
.PARAMETER Path
    If this parameter is given then the UserName is ignored, no folder lookup is performed,
    and the credential is read from this file directly.
.EXAMPLE
    Set-SavedCredential -Credential (Get-Credential 'Administrator')

    This will prompt you to enter the password for the Administrator credential.
    It will save it into a file as described above.
    
    To get the credential back (or in another session)

    Get-SavedCredential -UserName 'Administrator'

    The UserName parameter corresponds to the UserName given by the Set-SavedCredential cmdlet
#>
function Set-SavedCredential {
    [CmdletBinding()]
    [OutputType([void])]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [pscredential]
        $Credential,

        [System.String]
        $Path = $null
    )

    $Filename = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName))

    # If a path was not given
    if ([string]::IsNullOrEmpty($Path)) {

        # Try these environment variables, in order
        # Using the current directory '.' as a fallback
        foreach ($dir in @($env:APPDATA, $env:XDG_CONFIG_HOME, $env:HOME, '.')) {
            Write-Error $dir
            # If the variable is set, use it as a prefix to the filename
            if ($dir.Length -gt 0) {
                $Path = "$($dir)/Credential-Agent/$($Filename).xml"
                # Stop after the first set variable
                break
            }
        }
    }

    # Export the pscredential to the xml file
    [void](Export-Clixml -Path $Path -InputObject $Credential)
}
