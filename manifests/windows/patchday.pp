# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array $updates
) {
  if $updates.size > 0 {
    if $facts['os_patching']['reboots']['reboot_required'] == true {
      Windows_updates::Kb {
        require => Reboot['Patching as Code - Patch Reboot']
      }
      notify { 'Found pending reboot, performing reboot before patching...':
        schedule => 'Patching as Code - Patch Window',
        notify   => Reboot['Patching as Code - Patch Reboot']
      }
    } else {
      Windows_updates::Kb {
        notify => Reboot['Patching as Code - Patch Reboot']
      }
    }

    reboot { 'Patching as Code - Patch Reboot':
      apply    => 'finished',
      schedule => 'Patching as Code - Patch Window'
    }

    $updates.each | $kb | {
      windows_updates::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - Patch Window',
      }
    }

  }

}
