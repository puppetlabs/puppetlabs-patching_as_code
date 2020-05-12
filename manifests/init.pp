# Class: patching_as_code
# Framework for patch mgmt as code.
#
class patching_as_code(
  Enum['always', 'testing', 'early', 'primary', 'secondary', 'late', 'never'] $patch_group,
  Hash $patch_schedule,
  Array $blacklist,
  Array $whitelist,
) {
  # Ensure os_patching module is used
  include os_patching

  # Determine if today is Patch Day for this node's $patch_group
  $bool_patch_day = patching_as_code::is_patchday(
    $patch_schedule[$patch_group]['day_of_week'],
    $patch_schedule[$patch_group]['count_of_week']
  )

  if $bool_patch_day {
    if $facts['os_patching'] {
      $available_updates = $facts['kernel'] ? {
        'windows' => $facts['os_patching']['missing_update_kbs'],
        'Linux'   => $facts['os_patching']['package_updates'],
        default   => []
      }
    }
    else {
      $available_updates = []
    }

    case $whitelist.count {
      0: {
        $updates_to_install = $available_updates.filter |$item| { !($item in $blacklist) }
      }
      default: {
        $whitelisted_updates = $available_updates.filter |$item| { $item in $whitelist }
        $updates_to_install = $whitelisted_updates.filter |$item| { !($item in $blacklist) }
      }
    }

    case $patch_group {
      'always': {
        schedule { 'Patching as Code - Patch Window':
          range  => '00:00 - 23:59',
          repeat => 1440
        }
      }
      'never': {
        schedule { 'Patching as Code - Patch Window':
          period => 'never',
        }
      }
      default: {
        schedule { 'Patching as Code - Patch Window':
          range   => $patch_schedule[$patch_group]['hours'],
          weekday => $patch_schedule[$patch_group]['day_of_week'],
          repeat  => $patch_schedule[$patch_group]['max_runs']
        }
      }
    }

    case $facts['kernel'] {
      'windows': {
        class { 'patching_as_code::windows::patchday':
          updates => $updates_to_install
        }
      }
      'Linux': {
        class { 'patching_as_code::linux::patchday':
          updates => $updates_to_install
        }
      }
      default: {
        fail('Unsupported operating system!')
      }
    }
  }
}
