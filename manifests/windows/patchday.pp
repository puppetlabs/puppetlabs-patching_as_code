# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array   $updates,
  String  $patch_fact,
  Boolean $reboot,
  Boolean $reboot_if_needed
) {

  $fact_refresh = Exec["${patch_fact}::exec::fact"]
  $patch_reboot = $reboot_if_needed ? {
    true  => Exec['Patching as Code - Patch Reboot'],
    false => Reboot['Patching as Code - Patch Reboot']
  }

  $updates.each | $kb | {
    $triggers = $reboot ? {
      true  => [ $fact_refresh, $patch_reboot ],
      false => [ $fact_refresh ]
    }
    patching_as_code::kb { $kb:
      ensure      => 'present',
      maintwindow => 'Patching as Code - Patch Window',
      notify      => $triggers
    }
  }
}
