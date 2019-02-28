<#
.Synopsis
   Sends a file to the given computer
.DESCRIPTION
   Sends a file to the remote computer using psremoting
#>
function Send-File
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$LocalPath,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$ComputerName,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]$RemotePath,

        [pscredential]$Credential
    )

    Begin
    {
    }
    Process
    {
        # read in the bytes
        [byte[]]$fileData = [System.IO.File]::ReadAllBytes($LocalPath);

        # remote to the maching
        Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock {
            # write the bytes
            [System.IO.FIle]::WriteAllBytes($Using:RemotePath, $Using:fileData)
        }
    }
    End
    {
    }
}