Function Write-Info { Write-Output "[$($env:COMPUTERNAME)]INFO:`t$($args)" -ForeGroundColor Green; };
Function Write-Warn { Write-Output "[$($env:COMPUTERNAME)]WARN:`t$($args)" -ForeGroundColor Yellow; };
Function Write-Crit { Write-Output "[$($env:COMPUTERNAME)]CRIT:`t$($args)" -ForeGroundColor Red; };
