#requires -Version 5.1
<#
.SYNOPSIS
    Endpoint Network Latency Monitor.
.DESCRIPTION
    Read-only endpoint latency and response monitoring reporter.
#>
[CmdletBinding()]
param([string[]]$Targets=@('8.8.8.8','1.1.1.1','www.microsoft.com'),[int]$Count=5,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Latency_Monitor_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$raw=@();$summary=@()
foreach($target in $Targets){$samples=@();for($i=1;$i -le $Count;$i++){try{$r=Test-Connection -ComputerName $target -Count 1 -ErrorAction Stop|Select-Object -First 1;$ms=[double]$r.ResponseTime;$ok=$true}catch{$ms=$null;$ok=$false};$row=[PSCustomObject]@{Target=$target;Sample=$i;Success=$ok;ResponseTimeMs=$ms;TestedAt=Get-Date};$raw+=$row;if($ok){$samples+=$ms}}
$summary+=[PSCustomObject]@{Target=$target;Sent=$Count;Successful=$samples.Count;Failed=$Count-$samples.Count;MinimumMs=$(if($samples){[math]::Round(($samples|Measure-Object -Minimum).Minimum,2)}else{$null});AverageMs=$(if($samples){[math]::Round(($samples|Measure-Object -Average).Average,2)}else{$null});MaximumMs=$(if($samples){[math]::Round(($samples|Measure-Object -Maximum).Maximum,2)}else{$null})}}
$raw|Export-Csv (Join-Path $OutputPath "latency_samples_$stamp.csv") -NoTypeInformation -Encoding UTF8
$summary|Export-Csv (Join-Path $OutputPath "latency_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Samples=$raw;Summary=$summary}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "latency_report_$stamp.json") -Encoding UTF8
$html="<h1>Endpoint Network Latency</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$($summary|ConvertTo-Html -Fragment)<h2>Samples</h2>$($raw|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Network Latency Monitor'|Set-Content (Join-Path $OutputPath "latency_report_$stamp.html") -Encoding UTF8
$summary|Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
