# Class: patching_as_code::linux::patchday
# Performs the actual patching on Linux
#
class patching_as_code::linux::patchday (
  Array $updates,
  String $patch_fact
) {
  if $updates.size > 0 {
    if $facts[$patch_fact]['reboots']['reboot_required'] == true {
      Package {
        require => Reboot['Patching as Code - Patch Reboot']
      }
      notify { 'Found pending reboot, performing reboot before patching...':
        schedule => 'Patching as Code - Patch Window',
        notify   => Reboot['Patching as Code - Patch Reboot']
      }
    } else {
      Package {
        notify => Reboot['Patching as Code - Patch Reboot']
      }
    }

    reboot { 'Patching as Code - Patch Reboot':
      apply    => 'finished',
      schedule => 'Patching as Code - Patch Window'
    }

    exec { 'Clean Yum before updates':
      command  => 'yum clean all',
      path     => '/usr/bin',
      schedule => 'Patching as Code - Patch Window'
    }

    $updates.each | $package | {
      package { $package:
        ensure   => 'latest',
        schedule => 'Patching as Code - Patch Window',
        require  => Exec['Clean Yum before updates'],
      }
    }

  }

}
