<#
.Synopsis
   Get the BitLocker keys for the volume(s) of one or many computers.
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-BitLockerKeys
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 working directory
        $working_directory = "$env:USERPROFILE",

        # Param2 searchbase
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName = "localhost"
    )

    if ((Test-Path "$working_directory\PowerShell") -eq $false) {New-Item -ItemType Directory -Path "$working_directory\PowerShell"}
    

    while ($true) {
        foreach ($remotecomputername in $ComputerName){
            Invoke-Command -ComputerName $remotecomputername -AsJob -ScriptBlock {

                $encryptedvolumes = Get-BitLockerVolume | Where-Object {$_.VolumeStatus -eq "FullyEncrypted"} | sort MountPoint

                [System.Array]$arraytoexport = @()

                foreach ($mountpoint in $encryptedvolumes)
                {
                    $encryptedvolumesandkeys = Get-BitLockerVolume $mountpoint | select -ExpandProperty KeyProtector - | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} | select KeyProtectorType,KeyProtectorId,RecoveryPassword #| ft -AutoSize KeyProtectorType,KeyProtectorId,RecoveryPassword

                    $arraytoexport +=[pscustomobject]@{
                        'Date'=Get-Date
                        'ComputerName'=$mountpoint.ComputerName
                        'MountPoint'=$mountpoint.MountPoint
                        'KeyProtectorType'=$encryptedvolumesandkeys.KeyProtectorType
                        'KeyProtectorId'=$encryptedvolumesandkeys.KeyProtectorId
                        'RecoveryPassword'=$encryptedvolumesandkeys.RecoveryPassword
                    }
                }
                $arraytoexport
            }
        }
        #Receive-job

        $counterchecks = 0
        while ((Get-Job).count -ne 0 -and $counterchecks -lt 100){
                foreach( $job in Get-Job) {
                    if ($job.State -eq [System.Management.Automation.JobState]::Completed) {
                        $jobdata = Receive-Job $job
                
                                $jobdata | Export-Csv "$working_directory\BitLocker_Keys.csv" -NoTypeInformation -Append

                        Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Saved"
                        Remove-Job $job;
                    } elseif ($job.State -eq [System.Management.Automation.JobState]::Failed) {
                        Remove-Job $job;
                        Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Failed"
                    } elseif ($job.State -eq [System.Management.Automation.JobState]::Disconnected) {
                        Stop-Job $job;
                        Remove-Job $job;
                        Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Disconnected"
                    }
                }
                $counterchecks ++
                Write-Host $counterchecks
                sleep -Seconds 1
        }

        [System.Array]$csvdata = Import-Csv (Get-ChildItem $working_directory -Filter "BitLocker_Keys*.csv").fullname
        $csvdataunique = $csvdata | sort ComputerName,KeyProtectorId,RecoveryPassword -Unique
        #$csvdataunique | ft -AutoSize
        #$csvdata | measure
        #$csvdataunique | measure
        $csvdataunique | Export-Csv "$working_directory\BitLocker_Keys_Master.csv" -NoTypeInformation
        Get-ChildItem $working_directory -Filter "BitLocker_Keys*.csv" | Remove-Item -Exclude "BitLocker_Keys_Master.csv"

        Write-Host "Waiting to run again.  $(Get-Date -UFormat `"%Y/%m/%d %H:%M`")"
        sleep -Seconds (60 * 5)
    }
}
