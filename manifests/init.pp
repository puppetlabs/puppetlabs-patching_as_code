# Class: patching_as_code
# Framework for patch mgmt as code.
#
class patching_as_code(
  String            $patch_group,
  Hash              $patch_schedule,
  Array             $blacklist,
  Array             $whitelist,
  Optional[Boolean] $use_pe_patch = true, # Use the pe_patch module if available (PE 2019.8+)
) {
  # Verify the $patch_group value points to a valid patch schedule
  unless $patch_schedule[$patch_group] or $patch_group in ['always', 'never'] {
    fail("Patch group ${patch_group} is not valid as no associated schedule was found!
    Ensure the patching_as_code::patch_schedule parameter contains a schedule for this patch group.")
  }

  # Determine which patching module to use
  if defined('pe_patch') and $use_pe_patch {
    $pe_patch = true
  } else {
    $pe_patch = false
  }

  # Ensure the correct patching module is used and set patch_window/patch_group
  if $pe_patch {
    $patch_fact = 'pe_patch'
    class { 'pe_patch':
      patch_group => $patch_group,
    }
  } else {
    $patch_fact = 'os_patching'
    class { 'os_patching':
      patch_window => $patch_group,
    }
  }

  # Determine if today is Patch Day for this node's $patch_group
  case $patch_group {
    'always': {
      $bool_patch_day = true
      schedule { 'Patching as Code - Patch Window':
        range  => '00:00 - 23:59',
        repeat => 1440
      }
      $reboot = 'always'
    }
    'never': {
      $bool_patch_day = false
      schedule { 'Patching as Code - Patch Window':
        period => 'never',
      }
      $reboot = 'never'
    }
    default: {
      $bool_patch_day = patching_as_code::is_patchday(
        $patch_schedule[$patch_group]['day_of_week'],
        $patch_schedule[$patch_group]['count_of_week']
      )
      schedule { 'Patching as Code - Patch Window':
        range   => $patch_schedule[$patch_group]['hours'],
        weekday => $patch_schedule[$patch_group]['day_of_week'],
        repeat  => $patch_schedule[$patch_group]['max_runs']
      }
      $reboot = $patch_schedule[$patch_group]['reboot']
    }
  }

  if $bool_patch_day {
    if $facts[$patch_fact] {
      $available_updates = $facts['kernel'] ? {
        'windows' => $facts[$patch_fact]['missing_update_kbs'],
        'Linux'   => $facts[$patch_fact]['package_updates'],
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

    case $facts['kernel'] {
      'windows': {
        class { 'patching_as_code::windows::patchday':
          updates    => $updates_to_install,
          patch_fact => $patch_fact,
          reboot     => $reboot
        }
      }
      'Linux': {
        class { 'patching_as_code::linux::patchday':
          updates    => $updates_to_install,
          patch_fact => $patch_fact,
          reboot     => $reboot
        }
      }
      default: {
        fail('Unsupported operating system!')
      }
    }
  }
}
