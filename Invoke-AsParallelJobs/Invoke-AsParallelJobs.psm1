<#
.Synopsis
   Invokes a scriptblock on multiple machines using Invoke-Command cmdlet and powershell jobs
.DESCRIPTION
   This cmdlet runs a scriptblock on remote machines.
   It runs them in parallel using -job parameter to Invoke-Command.
   It returns the result from the job.
.EXAMPLE
   Invoke-AsParallelJobs -Credential $c -ComputerName "","" -Scriptblock {} -OnComplete {} -OnFailure {} -OnOther {}
.EXAMPLE
   Invoke-AsParallelJobs -Credential $c -ComputerName example01 -ScriptBlock {
      Get-Service -DisplayName '*Volume*'
   } | ForEach-Object {
      Write-Host $_.ComputerName
      $_.Result | Format-Table
   }
#>
function Invoke-AsParallelJobs
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([void])]
    Param
    (
        # Param1 help description
        [pscredential]
        $Credential,

        # Param2 help description
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [System.String[]]
        $ComputerName,

        # Param2 help description
        [scriptblock]
        $ScriptBlock = {},

        # Param2 help description
        [scriptblock]
        $OnComplete = {},

        # Param2 help description
        [scriptblock]
        $OnFailure = {},

        # Param2 help description
        [scriptblock]
        $OnOther = {}
    )

    Begin
    {
        $_jobs = ($ComputerName | ForEach-Object {
            Invoke-Command -Credential $Credential -ComputerName $_ -ScriptBlock $ScriptBlock -AsJob;
        });
    }
    Process
    {
        #[System.Collections.ArrayList]$results = @();
        while ( ($_jobs | Get-Job -ErrorAction SilentlyContinue).Count -gt 0) {
            (($_jobs | Get-Job -ErrorAction SilentlyContinue) | Wait-Job -Any -Timeout 10) | ForEach-Object {
                if ($_.State -eq [System.Management.Automation.JobState]::Completed) {
                    $_ | & $OnComplete
                    [pscustomobject]@{
                        "ComputerName"=$_.Location;
                        "State"="OK";
                        "Result"=($_ | Receive-Job);
                    }
                    $_ | Remove-Job | Out-Null;
                    continue;
                }
                if ($_.State -eq [System.Management.Automation.JobState]::Failed) {
                    $_ | & $OnFailure
                    [pscustomobject]@{
                        "ComputerName"=$_.Location;
                        "State"="FAILED";
                        "Result"=($_ | Receive-Job);
                    }
                    $_ | Remove-Job | Out-Null;
                    continue;
                }
                if ($_.State -ne [System.Management.Automation.JobState]::Running) {
                    Write-Verbose "${_.Name} [ ${_.Id} ] has state ${_.State}";
                    $_ | & $OnOther
                }
            }
        }
    }
    End {}
}