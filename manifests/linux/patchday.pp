# Class: patching_as_code::linux::patchday
# Performs the actual patching on Linux
#
class patching_as_code::linux::patchday (
  Array $updates,
  String $patch_fact,
  Boolean $reboot
) {

  case $facts['package_provider'] {
    'yum': {
      Package {
        require  => Exec['Patching as Code - Clean Yum'],
      }
      exec { 'Patching as Code - Clean Yum':
        command  => 'yum clean all',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    default: { }
  }

  $updates.each | $package | {
    if $reboot {
      package { $package:
        ensure   => 'latest',
        schedule => 'Patching as Code - Patch Window',
        notify   => Reboot['Patching as Code - Patch Reboot']
      }
    } else {
      package { $package:
        ensure   => 'latest',
        schedule => 'Patching as Code - Patch Window'
      }
    }
  }

}
