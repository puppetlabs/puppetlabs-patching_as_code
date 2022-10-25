# Class: patching_as_code::windows::patchday
# 
# @summary
#   This class gets called by init.pp to perform the actual patching on Windows.
# @param [Array] updates
#   List of Windows KB patches to install.
# @param [Array] choco_updates
#   List of Chocolatey packages to update.
# @param [Array] high_prio_updates
#   List of high-priority Windows KB patches to install.
# @param [Array] high_prio_choco_updates
#   List of high-priority Chocolatey packages to update.
class patching_as_code::windows::patchday (
  Array $updates,
  Array $choco_updates,
  Array $high_prio_updates = [],
  Array $high_prio_choco_updates = []
) {
  if $updates.count > 0 {
    $updates.each | $kb | {
      patching_as_code::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - Patch Window',
      }
    }
  }

  if $high_prio_updates.count > 0 {
    $high_prio_updates.each | $kb | {
      patching_as_code::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - High Priority Patch Window',
      }
    }
  }

  if $choco_updates.count > 0 {
    $choco_updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - Patch Window',
        chocolatey   => true,
      }
    }
  }

  if $high_prio_choco_updates.count > 0 {
    $high_prio_choco_updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - High Priority Patch Window',
        chocolatey   => true,
      }
    }
  }

  anchor { 'patching_as_code::patchday::end': } #lint:ignore:anchor_resource
}
