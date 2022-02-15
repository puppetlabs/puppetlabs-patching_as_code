# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array $updates,
  Array $choco_updates,
) {

  $updates.each | $kb | {
    patching_as_code::kb { $kb:
      ensure      => 'present',
      maintwindow => 'Patching as Code - Patch Window'
    }
  }

  $choco_updates.each | $package | {
    patch_package { $package:
      patch_window => 'Patching as Code - Patch Window',
      chocolatey   => true
    }
  }

  anchor {'patching_as_code::patchday::end':}
}
