# Class: patching_as_code::windows::patchday
# Performs the actual patching on Windows
#
class patching_as_code::windows::patchday (
  Array   $updates,
  String  $patch_fact,
) {

  $updates.each | $kb | {
    patching_as_code::kb { $kb:
      ensure      => 'present',
      maintwindow => 'Patching as Code - Patch Window'
    }
  }

  anchor {'patching_as_code::patchday::end':}
}
