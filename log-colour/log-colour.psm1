Function Log-Info { Write-Host "[$($env:COMPUTERNAME)]INFO:`t$($args)" -ForeGroundColor Green; };
Function Log-Warn { Write-Host "[$($env:COMPUTERNAME)]WARN:`t$($args)" -ForeGroundColor Yellow; };
Function Log-Crit { Write-Host "[$($env:COMPUTERNAME)]CRIT:`t$($args)" -ForeGroundColor Red; };
