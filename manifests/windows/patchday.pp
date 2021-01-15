# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array   $updates,
  String  $patch_fact,
  Boolean $reboot
) {

  $fact_refresh = Exec["${patch_fact}::exec::fact"]
  $patch_reboot = Reboot['Patching as Code - Patch Reboot']

  $updates.each | $kb | {
    $triggers = $reboot ? {
      true  => [ $fact_refresh, $patch_reboot ],
      false => [ $fact_refresh ]
    }
    windows_updates::kb { $kb:
      ensure      => 'present',
      maintwindow => 'Patching as Code - Patch Window',
      notify      => $triggers
    }
  }
}
