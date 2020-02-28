<#
.Synopsis
    Run the SIMS.net commandReporter.exe to run a report from SIMS
.DESCRIPTION
    This cmdlet runs the SIMS.net commandReporter.exe to run a pre-defined
    export of data from SIMS.
    You cannot make new reports on the fly, this only exports already created,
    named reports from SIMS.

    Use -Path to specify an output csv file
    Use -PassThru to return the results directly
    Use -Path and -PassThru to put the results into a file and return them
.EXAMPLE
    Invoke-SIMSreport -Report 'export all staff' -Credential $Cred -Path 'C:\staff.csv'
.EXAMPLE
    $data = Invoke-SIMSreport -Report 'export all staff' -Credential $Cred -PassThru
#>
function Invoke-SIMSreport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Report,

        [Parameter(Mandatory = $true)]
        [pscredential]$Credential,

        [Parameter(Mandatory = $false)]
        [string]$Path = "",

        [Parameter(Mandatory = $false)]
        [Switch]$PassThru
    )

    if (("" -eq $Path) -and (-not $PassThru))
    {
        Write-Error -Message '-Path is "" and -PassThru was not present: Either specify -Path or -PassThru (or both)'
        return
    }

    # Extract the plaintext passwords from the pscredential
    $NetworkCredential = $Credential.GetNetworkCredential()
    $Username = $NetworkCredential.UserName
    $Password = $NetworkCredential.Password

    # The Path parameter is optional so create a temp filename if none was given
    if ("" -eq $Path)
    {
        $TempFileUsed = $true
        [string]$TempFile = [System.IO.Path]::GetTempFileName()
        [string]$Path = Move-Item -Path $TempFile -Destination ($TempFile + ".csv") -PassThru | Select-Object -ExpandProperty FullName
        Write-Verbose "Invoke-SIMSreport: Created temp file '$Path'"
    }

    # The call operator is used here instead of
    # Start-Process because they are different.
    # Start-Process opens a new terminal and PowerShell
    # cannot get the output from the program.
    # The call operator captures the output from the command
    # and can be accessed from PowerShell.
    & 'C:\Program Files\SIMS\SIMS .net\commandReporter.exe' "/user:$Username" "/password:$Password" "/report:$Report" "/output:$Path" | Tee-Object -Variable 'ReportOut' | Write-Verbose

    # Check if commandReporter returned any <CommandReporterError> xml
    if ($ReportOut | Select-String -Pattern '<CommandReporterError>') {
        Write-Error -Message ([xml]($ReportOut | Select-String '<CommandReporterError>') | Select-Object -ExpandProperty 'CommandReporterError')
        # Clean up the temporary file on exit
        if ($TempFileUsed)
        {
            Write-Verbose "Removing temp file"
            Remove-Item -Path $Path -ErrorAction SilentlyContinue | Write-Verbose
        }
        return
    }

    # Check if the file exists, or if it is empty
    if ((-not (Test-Path -Path $Path)) -or (Get-Item -Path $Path).Length -eq 0)
    {
        Write-Error -Message 'commandReporter.exe likely failed; Check verbose output'
        # Clean up the temporary file on exit
        if ($TempFileUsed)
        {
            Write-Verbose "Removing temp file"
            Remove-Item -Path $Path -ErrorAction SilentlyContinue | Write-Verbose
        }
        return
    }

    if ($PassThru)
    {
        # Import the file and (implicitly) return it to the caller
        Import-Csv -Path $Path
        # Clean up the temporary file on exit
        if ($TempFileUsed)
        {
            Write-Verbose "Removing temp file"
            Remove-Item -Path $Path -ErrorAction SilentlyContinue | Write-Verbose
        }
    }
}
