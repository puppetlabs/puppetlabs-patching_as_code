# Class: patching_as_code
# Framework for patch mgmt as code.
#
class patching_as_code(
  String            $patch_group,
  Hash              $patch_schedule,
  Array             $blacklist,
  Array             $whitelist,
  Array             $pre_patch_commands,
  Array             $post_patch_commands,
  Array             $pre_reboot_commands,
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
      $_reboot = 'always'
    }
    'never': {
      $bool_patch_day = false
      schedule { 'Patching as Code - Patch Window':
        period => 'never',
      }
      $_reboot = 'never'
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
      $_reboot = $patch_schedule[$patch_group]['reboot']
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

    $reboot = case $_reboot {
      'always':   {true}
      'never':    {false}
      'ifneeded': {$facts[$patch_fact]['reboots']['reboot_required']}
      default:    {false}
    }

    if $available_updates.count > 0 {
      case $facts['kernel'].downcase() {
        /(windows|linux)/: {
          # Run pre-patch commands if provided
          $pre_patch_commands.each | $cmd, $cmd_opts | {
            exec { "Patching as Code - Before patching - ${cmd}":
              *      => $cmd_opts,
              before => Class["patching_as_code::${0}::patchday"]
            }
          }
          # Perform main patching run
          class { "patching_as_code::${0}::patchday":
            updates    => $updates_to_install,
            patch_fact => $patch_fact,
            reboot     => $reboot
          }
          if $reboot == true {
            $post_patch_commands.each | $cmd, $cmd_opts | {
              exec { "Patching as Code - After patching - ${cmd}":
                *       => $cmd_opts,
                require => Class["patching_as_code::${0}::patchday"],
                before  => Reboot['Patching as Code - Patch Reboot'],
              } -> Exec <| tag == 'patching_as_code_pre_reboot' |>
            }
            $pre_reboot_commands.each | $cmd, $cmd_opts | {
              exec { "Patching as Code - Before reboot - ${cmd}":
                *       => $cmd_opts,
                require => Class["patching_as_code::${0}::patchday"],
                before  => Reboot['Patching as Code - Patch Reboot'],
                tag     => ['patching_as_code_pre_reboot']
              }
            }
          } else {
            $post_patch_commands.each | $cmd, $cmd_opts | {
              exec { "Patching as Code - After patching - ${cmd}":
                *       => $cmd_opts,
                require => Class["patching_as_code::${0}::patchday"]
              }
            }
          }
        }
        default: {
          fail('Unsupported operating system!')
        }
      }
    }
  }
}
