#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded local network recovery with pre/post latency evidence. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','FlushDns','RenewDhcp')][string]$Action='Diagnose',[string[]]$Targets=@('1.1.1.1','8.8.8.8','login.microsoftonline.com'),[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Endpoint_Latency_Repair'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$s=Get-Date -Format yyyyMMdd_HHmmss
function Measure-Targets{foreach($t in $Targets){$r=@(Test-Connection $t -Count 3 -ErrorAction SilentlyContinue);[pscustomobject]@{Target=$t;Replies=$r.Count;AverageMs=if($r){[math]::Round(($r|Measure-Object ResponseTime -Average).Average,2)}else{$null}}}}
$before=@(Measure-Targets);$before|Export-Csv (Join-Path $OutputPath "before_$s.csv") -NoTypeInformation
if($Action-eq'Diagnose'){exit 0}
try{if($Action-eq'FlushDns'-and$PSCmdlet.ShouldProcess('DNS client cache','Clear')){Clear-DnsClientCache}elseif($Action-eq'RenewDhcp'-and$PSCmdlet.ShouldProcess('DHCP leases','Renew')){& ipconfig.exe /renew;if($LASTEXITCODE-ne 0){throw "ipconfig exited $LASTEXITCODE"}}}catch{Write-Error $_;exit 5}
$after=@(Measure-Targets);$after|Export-Csv (Join-Path $OutputPath "after_$s.csv") -NoTypeInformation
if(@($after|Where-Object Replies -gt 0).Count-eq 0){exit 6};exit 0
