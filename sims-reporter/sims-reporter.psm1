<#
.Synopsis
    Run the SIMS.net commandReporter.exe to run a report from SIMS
.DESCRIPTION
    This cmdlet runs the SIMS.net commandReporter.exe to run a pre-defined
    export of data from SIMS.
    You cannot make new reports on the fly, this only exports already created,
    named reports from SIMS.
.EXAMPLE
    Invoke-SIMSreport -Report 'export all staff' -Credential $Cred -Path 'C:\staff.csv'
#>
function Invoke-SIMSreport {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Report,
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential,
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $CommandReporter = "C:\Program Files\SIMS\SIMS .net\commandReporter.exe"

    if (!(Test-Path -Path $CommandReporter)) {
        Write-Error "The file does not exist: $CommandReporter"
        return
    }

    $NetworkCredential = $Credential.GetNetworkCredential()
    $Username = $NetworkCredential.UserName
    $Password = $NetworkCredential.Password

    $args = @(
        "/user:$Username",
        "/password:$Password",
        "/report:$Report",
        "/output:$Path"
    )
    # Note; this isn't the same as argument splatting,
    # we're just passing an array to the ArgumentList parameter
    Start-Process -FilePath $CommandReporter -ArgumentList $args -WorkingDirectory (Get-Location | Select-Object -ExpandProperty Path) -Wait
}
