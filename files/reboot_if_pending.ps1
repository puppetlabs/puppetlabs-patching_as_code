function Get-PendingReboot {
    #Copied from http://ilovepowershell.com/2015/09/10/how-to-check-if-a-server-needs-a-reboot/
    #Adapted from https://gist.github.com/altrive/5329377
    #Based on <http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542>

    $rebootPending = $false

    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { $rebootPending = $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { $rebootPending = $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { $rebootPending = $true }
    try {
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if (($null -ne $status) -and $status.RebootPending) {
            $rebootPending = $true
        }
    }
    catch { }

    if ($rebootPending) {
        Write-Host "Patching_as_code: A reboot is required"
    } else {
        Write-Host "Patching_as_code: No reboot is needed, doing nothing"
    }

    # return result
    $rebootPending
}

if (Get-PendingReboot) {
    Write-Host "Patching_as_code: Scheduling a reboot to happen in 5 minutes"
    & shutdown /r /t 300 /c "Patching_as_code: Rebooting system due to a pending reboot after patching" /d p:2:17
}