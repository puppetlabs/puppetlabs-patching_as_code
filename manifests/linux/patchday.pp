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
    'dnf': {
      Package {
        require  => Exec['Patching as Code - Clean DNF'],
      }
      exec { 'Patching as Code - Clean DNF':
        command  => 'dnf clean all',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    'apt': {
      Package {
        require  => Exec['Patching as Code - Clean Apt'],
      }
      exec { 'Patching as Code - Clean Apt':
        command  => 'apt-get clean',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    'zypper': {
      Package {
        require  => Exec['Patching as Code - Clean Zypper'],
      }
      exec { 'Patching as Code - Clean Zypper':
        command  => 'zypper cc --all',
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
        notify   => [
          Exec["${patch_fact}::exec::fact"],
          Reboot['Patching as Code - Patch Reboot']
        ]
      }
    } else {
      package { $package:
        ensure   => 'latest',
        schedule => 'Patching as Code - Patch Window',
        notify   => [
          Exec["${patch_fact}::exec::fact"],
        ]
      }
    }
  }

}
