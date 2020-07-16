# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array $updates,
  String $patch_fact,
  Boolean $reboot
) {

  $updates.each | $kb | {
    if $reboot {
      windows_updates::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - Patch Window',
        notify      => Reboot['Patching as Code - Patch Reboot']
      }
    } else {
      windows_updates::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - Patch Window'
      }
    }
  }
}
