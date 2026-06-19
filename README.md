# Endpoint Network Latency Monitor

A read-only PowerShell toolkit for endpoint latency and response monitoring.

## Features

- Multiple target monitoring
- Average, minimum, and maximum response time
- Success and failure counts
- CSV, JSON, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Endpoint_Network_Latency_Monitor.ps1
```

Custom targets and sample count:

```powershell
.\Endpoint_Network_Latency_Monitor.ps1 -Targets 8.8.8.8,www.microsoft.com -Count 10
```

## Safety

Diagnostic-only. It performs standard connectivity tests and does not change network settings.
