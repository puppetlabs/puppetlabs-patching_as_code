$defaultGateways = get-netroute -DestinationPrefix '0.0.0.0/0'
$gwMetrics = @(foreach ($gw in $defaultGateways) {
    New-Object -Type PSObject -Property @{
        'ifIndex' = $gw.InterfaceIndex
        'ifMetric' = $gw.RouteMetric + $gw.InterfaceMetric
    }
})

$ifIndex = ($gwMetrics | ? IfMetric -eq ($gwMetrics | Measure-Object -Property ifMetric -Minimum).Minimum).IfIndex
$if = Get-NetAdapter -InterfaceIndex $ifIndex

$blnMetered = $false
if (Test-Path "HKLM:\SOFTWARE\Microsoft\DusmSvc\Profiles\$($if.InterfaceGuid)\*") {
    if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\DusmSvc\Profiles\$($if.InterfaceGuid)\*").UserCost -eq 2) {
        $blnMetered = $true
    }
}

$blnMetered | ConvertTo-Json
