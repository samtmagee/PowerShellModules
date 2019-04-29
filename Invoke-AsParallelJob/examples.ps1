Invoke-AsParallelJobs -Credential (Load-Credential 'isleworthsyon\mcarteradmin') -ComputerName (Get-RegexADComputer -Regex 'CN=3020-..,' | Select-Object -ExpandProperty cn) -ScriptBlock {
    Get-Service -DisplayName '*Volume*'
    #Get-WmiObject -Class Win32_UserProfile | Select-Object LocalPath
} | ForEach-Object {
    Log-Info $_.ComputerName
    $_.Result | Format-Table
}

Invoke-AsParallelJobs -Credential (Load-Credential 'isleworthsyon\mcarteradmin') -ComputerName "its-02","smagee-pc" -ScriptBlock {
    $volumes = (Get-BitLockerVolume | Where-Object {$_.VolumeStatus -eq "FullyEncrypted"})
    
    $volumes | ForEach-Object {
        $vol = $_;
        $vol | Select-Object -ExpandProperty KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"} | ForEach-Object {
            [pscustomobject]@{'Date'=(Get-Date);'ComputerName'=$vol.ComputerName;'MountPoint'=$vol.MountPoint;'KeyProtectorType'=$_.KeyProtectorType;'KeyProtectorId'=$_.KeyProtectorId;'RecoveryPassword'=$_.RecoveryPassword;
            }
        }
    }
} -OnOther { Log-Warn $_.State; $_ | Remove-Job } | ForEach-Object {
    Log-Info $_.ComputerName
    $_.Result | Format-Table
}
