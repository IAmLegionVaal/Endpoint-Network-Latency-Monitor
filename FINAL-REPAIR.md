# Endpoint network recovery

Created by **Dewald Pretorius**.

```powershell
.\Repair-NetworkLatency.ps1 -Action Diagnose
.\Repair-NetworkLatency.ps1 -Action FlushDns -WhatIf
.\Repair-NetworkLatency.ps1 -Action RenewDhcp -Confirm
```

The workflow records latency before and after repair. It only clears the DNS cache or renews DHCP leases. Exit codes: `0` success, `5` action failure, `6` verification failure.
