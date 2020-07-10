# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array $updates,
  String $patch_fact,
  Enum['always', 'never', 'ifneeded'] $reboot
) {

  $_reboot = if $reboot == 'always' {
              true
            }
            elsif $reboot == 'never' {
              false
            }
            else {
              $facts[$patch_fact]['reboots']['reboot_required']
            }

  if $updates.size > 0 {
    if $facts[$patch_fact]['reboots']['reboot_required'] == true and $_reboot {
      Windows_updates::Kb {
        require => Reboot['Patching as Code - Patch Reboot']
      }
      notify { 'Found pending reboot, performing reboot before patching...':
        schedule => 'Patching as Code - Patch Window',
        notify   => Reboot['Patching as Code - Patch Reboot']
      }
    } elsif $_reboot {
      Windows_updates::Kb {
        notify => Reboot['Patching as Code - Patch Reboot']
      }
    }

    if $_reboot {
      reboot { 'Patching as Code - Patch Reboot':
        apply    => 'finished',
        schedule => 'Patching as Code - Patch Window'
      }
    }

    $updates.each | $kb | {
      windows_updates::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - Patch Window',
      }
    }

  }

}
