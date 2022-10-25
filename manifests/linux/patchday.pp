# Class: patching_as_code::linux::patchday
# 
# @summary
#   This class gets called by init.pp to perform the actual patching on Linux.
# @param [Array] updates
#   List of Linux packages to update.
# @param [Array] choco_updates
#   List of Chocolatey packages to update, which should always be empty for Linux. This parameter exists only for compability.
# @param [Array] high_prio_updates
#   List of high-priority Linux packages to update.
# @param [Array] high_prio_choco_updates
#   List of high-priority Chocolatey packages to update, which should always be empty for Linux. This parameter exists only for compability.
class patching_as_code::linux::patchday (
  Array $updates,
  Array $choco_updates = [],
  Array $high_prio_updates = [],
  Array $high_prio_choco_updates = []
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

  if $updates.count > 0 {
    exec { 'Patching as Code - Clean Cache':
      command  => $cmd,
      path     => $cmd_path,
      schedule => 'Patching as Code - Patch Window',
    }

    $updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - Patch Window',
        chocolatey   => false,
        require      => Exec['Patching as Code - Clean Cache'],
      }
    }
  }

  if $high_prio_updates.count > 0 {
    exec { 'Patching as Code - Clean Cache (High Priority)':
      command  => $cmd,
      path     => $cmd_path,
      schedule => 'Patching as Code - High Priority Patch Window',
    }

    $high_prio_updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - High Priority Patch Window',
        chocolatey   => false,
        require      => Exec['Patching as Code - Clean Cache (High Priority)'],
      }
    }
  }

  anchor { 'patching_as_code::patchday::end': } #lint:ignore:anchor_resource
}
