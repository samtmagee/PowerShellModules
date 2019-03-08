<#
.Synopsis
   Get the BitLocker key(s) for a computer.
.DESCRIPTION
   Get the BitLocker key(s) for the volume(s) of one or many computers.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-BitLockerKeys
{
    [CmdletBinding()]
    Param
    (
        # Computer or computers to check for BitLocker keys.
        [Parameter(Position=0)]
        [string[]]$ComputerName = "localhost",

        # Timeout in seconds for the Invoke-Command AsJob to run.
        [int]$TimeOut = 60
    )

    foreach ($remotecomputername in $ComputerName){
        Invoke-Command -ComputerName $remotecomputername -AsJob -ScriptBlock {

            $encryptedvolumes = Get-BitLockerVolume | Where-Object {$_.VolumeStatus -eq "FullyEncrypted"} | sort MountPoint

            [System.Array]$arraytoexport = @()

            foreach ($mountpoint in $encryptedvolumes)
            {
                $encryptedvolumesandkeys = Get-BitLockerVolume $mountpoint | select -ExpandProperty KeyProtector - | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} | select KeyProtectorType,KeyProtectorId,RecoveryPassword

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
        } | Out-Null
    }

    # Receive-Job
    [system.array]$jobdata = @()
    $counterchecks = 0
    while ((Get-Job).count -ne 0 -and $counterchecks -lt $TimeOut){
        foreach( $job in Get-Job) {
            if ($job.State -eq [System.Management.Automation.JobState]::Completed) {
                $jobdata += Receive-Job $job
                #Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Saved"
                Remove-Job $job;
            } elseif ($job.State -eq [System.Management.Automation.JobState]::Failed) {
                Remove-Job $job;
                #Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Failed"
            } elseif ($job.State -eq [System.Management.Automation.JobState]::Disconnected) {
                Stop-Job $job;
                Remove-Job $job;
                #Write-Host "$(Get-Date -UFormat `"%Y/%m/%d %H:%M`") - $($job.Location) Disconnected"
            }
        }
        $counterchecks ++
        #Write-Host $counterchecks
        sleep -Seconds 1

    }
    return $jobdata | sort ComputerName,MountPoint | ft -AutoSize Date,ComputerName,MountPoint,KeyProtectorType,KeyProtectorId,RecoveryPassword

}
