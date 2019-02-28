<#
.Synopsis
   Turn a scriptblock into an encoded command string
.DESCRIPTION
   Converts a scriptblock into an encoded command string
   for use with 'powershell -EncodedCommand <cmd>'
.EXAMPLE
   ConvertTo-EncodedCommand -scriptblock {Write-Host "Hello world"}
.EXAMPLE
   $b = {
     Write-Host "Hello, world!";
     Write-Host "Hello again!";
   }
   ConvertTo-EncodedCommand $b
#>
function ConvertTo-EncodedCommand
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # The scriptblock to convert
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [scriptblock]$ScriptBlock
    )

    Begin
    {
    }
    Process
    {
    [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptBlock));
    }
    End
    {
    }
}