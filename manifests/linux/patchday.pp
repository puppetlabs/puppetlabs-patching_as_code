# Class: patching_as_code::linux::patchday
# Performs the actual patching on Linux
#
class patching_as_code::linux::patchday (
  Array   $updates,
  String  $patch_fact,
) {

  case $facts['package_provider'] {
    'yum': {
      $cmd      = 'yum clean all'
      $cmd_path = '/usr/bin'
    }
    'dnf': {
      $cmd      = 'dnf clean all'
      $cmd_path = '/usr/bin'
    }
    'apt': {
      $cmd      = 'apt-get clean'
      $cmd_path = '/usr/bin'
    }
    'zypper': {
      $cmd      = 'zypper cc --all'
      $cmd_path = '/usr/bin'
    }
    default: {
      $cmd = 'true'
      $cmd_path = '/usr/bin'
    }
  }

  exec { 'Patching as Code - Clean Cache':
    command  => $cmd,
    path     => $cmd_path,
    schedule => 'Patching as Code - Patch Window'
  } -> anchor {'patching_as_code::patchday::start':
  } -> anchor {'patching_as_code::patchday::end':
    notify => Exec["${patch_fact}::exec::fact"]
  }

  $updates.each | $package | {
    patch_package { $package:
      patch_window => 'Patching as Code - Patch Window',
      triggers     => []
    }
  }
}
