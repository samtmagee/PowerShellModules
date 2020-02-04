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

    # Extract the plaintext passwords from the pscredential
    $NetworkCredential = $Credential.GetNetworkCredential()
    $Username = $NetworkCredential.UserName
    $Password = $NetworkCredential.Password

    # we have to use the call operator here instead of
    # Start-Process because they are actually different
    # and only the call operator works for this usecase.
    & "C:\Program Files\SIMS\SIMS .net\commandReporter.exe" "/user:$Username" "/password:$Password" "/report:$Report" "/output:$Path"
}
