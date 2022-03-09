# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
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
        maintwindow => 'Patching as Code - Patch Window'
      }
    }
  }

  notify {'List of high prio patches received':
    message => "${high_prio_updates}"
  }

  notify {'Count of high prio patches received':
    message => "${high_prio_updates.count}"
  }

  if $high_prio_updates.count > 0 {
    $updates.each | $kb | {
      patching_as_code::kb { $kb:
        ensure      => 'present',
        maintwindow => 'Patching as Code - High Priority Patch Window'
      }
    }
  }

  if $choco_updates.count > 0 {
    $choco_updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - Patch Window',
        chocolatey   => true
      }
    }
  }

  if $high_prio_choco_updates.count > 0 {
    $high_prio_choco_updates.each | $package | {
      patch_package { $package:
        patch_window => 'Patching as Code - High Priority Patch Window',
        chocolatey   => true
      }
    }
  }

  anchor {'patching_as_code::patchday::end':}
}
