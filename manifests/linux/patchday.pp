# Class: patching_as_code::linux::patchday
# Performs the actual patching on Linux
#
class patching_as_code::linux::patchday (
  Array   $updates,
  String  $patch_fact,
  Boolean $reboot
) {

  case $facts['package_provider'] {
    'yum': {
      $clean_exec = Exec['Patching as Code - Clean Yum']
      exec { 'Patching as Code - Clean Yum':
        command  => 'yum clean all',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    'dnf': {
      $clean_exec = Exec['Patching as Code - Clean DNF']
      exec { 'Patching as Code - Clean DNF':
        command  => 'dnf clean all',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    'apt': {
      $clean_exec = Exec['Patching as Code - Clean Apt']
      exec { 'Patching as Code - Clean Apt':
        command  => 'apt-get clean',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    'zypper': {
      $clean_exec = Exec['Patching as Code - Clean Zypper']
      exec { 'Patching as Code - Clean Zypper':
        command  => 'zypper cc --all',
        path     => '/usr/bin',
        schedule => 'Patching as Code - Patch Window'
      }
    }
    default: {
      $clean_exec = undef
    }
  }

  $fact_refresh = Exec["${patch_fact}::exec::fact"]
  $patch_reboot = Reboot['Patching as Code - Patch Reboot']

  $updates.each | $package | {
    $triggers = $reboot ? {
      true  => [ $fact_refresh, $patch_reboot ],
      false => [ $fact_refresh ]
    }
    unless Package[$package] {
      # Use a package resource to update otherwise unmanaged packages
      package { $package:
        ensure   => 'latest',
        schedule => 'Patching as Code - Patch Window',
        require  => $clean_exec,
        notify   => $triggers
      }
    }
    # Use a resource collector to temporarily override packages defined elsewhere
    Package <| title == $package |> {
      ensure   => 'latest',
      schedule => 'Patching as Code - Patch Window',
      require  => $clean_exec,
      notify   => $triggers
    }
  }

}
