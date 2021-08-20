# @summary
#   Framework for patch management as code. Works alongside the puppetlabs/pe_patch or albatrossflavour/os_patching modules
# 
# @example Using the module with defaults, or controlling options through Hiera
#   include patching_as_code
# 
# @example Forcing the classification of pe_patch on PE 2019.8.0+
#   class {'patching_as_code':
#     classify_pe_patch => true
#   }
# 
# @example Forcing the use of albatrossflavour/os_patching on PE 2019.8.0+
#   class {'patching_as_code':
#     use_pe_patch => false
#   }
# 
# @param Variant[String,Array[String]] patch_group
#   Name(s) of the patch_group(s) for this node. Must match one or more of the patch groups in $patch_schedule
#   To assign multiple patch groups, provide this parameter as an array
# @param [Hash] patch_schedule
#   Hash of available patch_schedules. Default schedules are in /data/common.yaml of this module
# @option patch_schedule [String] :day_of_week
#   Day of the week to patch, valid options: 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
# @option patch_schedule [Variant[Integer,Array[Integer]]] :count_of_week
#   Which week(s) in the month to patch, use number(s) between 1 and 5
# @option patch_schedule [String] :hours
#   Which hours on patch day to patch, define a range as 'HH:MM - HH:MM'
# @option patch_schedule [String] :max_runs
#   How many Puppet runs during the patch window can Puppet install patches. Must be at least 1.
# @option patch_schedule [String] :reboot
#   Reboot behavior, valid options: 'always', 'never', 'ifneeded'
# @param [Array] blocklist
#   List of updates to block from installing
# @param [Array] allowlist
#   List of updates that are allowed to be installed. Any updates not on this list get blocked.
# @param [Array] unsafe_process_list
#   List of processes that will cause patching to be skipped if any of the processes in the list are active on the system.
# @param [Hash] pre_patch_commands
#   Hash of command to run before patching
# @option pre_patch_commands [String] :command
#   The pre-patching command to execute
# @option pre_patch_commands [String] :path
#   (optional) The path for the command
# @option pre_patch_commands [String] :provider
#   (optional) The provider for the command
# @param [Hash] post_patch_commands
#   Hash of command to run after patching
# @option post_patch_commands [String] :command
#   The post-patching command to execute
# @option post_patch_commands [String] :path
#   (optional) The path for the command
# @option post_patch_commands [String] :provider
#   (optional) The provider for the command
# @param [Hash] pre_reboot_commands
#   Hash of command to run before rebooting
# @option pre_reboot_commands [String] :command
#   The pre-reboot command to execute
# @option pre_reboot_commands [String] :path
#   (optional) The path for the command
# @option pre_reboot_commands [String] :provider
#   (optional) The provider for the command
# @param [Optional[Boolean]] use_pe_patch
#   Use the pe_patch module if available (PE 2019.8+). Defaults to true.
# @param [Optional[Boolean]] classify_pe_patch
#   Controls if the pe_patch class (PE 2019.8+) is controlled by this module.
#   When enabled, this module will classify the node with pe_patch,
#   and set it's patch_group according to this module's patch_group.
#   When disabled (default), you can use PE's own "PE Patch Management" groups
#   to classify nodes with pe_patch. In that case, please make sure you match
#   the patch_group variable in pe_patch with the patch_group in patching_as_code
# @param [Optional[Boolean]] patch_on_metered_links
#   Controls if patches are installed when the active network connection is a
#   metered link. This setting only has affect for Windows operating systems.
#   When enabled, patching are installed even over a metered link.
#   When disabled (default), patches are not installed over a metered link.
# 
class patching_as_code(
  Variant[String,Array[String]] $patch_group,
  Hash                          $patch_schedule,
  Array                         $blocklist,
  Array                         $allowlist,
  Array                         $unsafe_process_list,
  Hash                          $pre_patch_commands,
  Hash                          $post_patch_commands,
  Hash                          $pre_reboot_commands,
  Optional[String]              $plan_patch_fact = undef,
  Optional[Boolean]             $enable_patching = true,
  Optional[Boolean]             $security_only = false,
  Optional[Boolean]             $use_pe_patch = true,
  Optional[Boolean]             $classify_pe_patch = false,
  Optional[Boolean]             $patch_on_metered_links = false,
) {
  # Create an extra stage to perform the reboot at the very end of the run
  stage { 'patch_reboot': }
  Stage['main'] -> Stage['patch_reboot']

  # Ensure we work with a $patch_groups array for further processing
  $patch_groups = Array($patch_group, true)

  # Verify if all of $patch_groups point to a valid patch schedule
  $patch_groups.each |$pg| {
    unless $patch_schedule[$pg] or $pg in ['always', 'never'] {
      fail("Patch group ${pg} is not valid as no associated schedule was found!
      Ensure the patching_as_code::patch_schedule parameter contains a schedule for this patch group.")
    }
  }

  # Verify the puppet_confdir from the puppetlabs/puppet_agent module is present
  unless $facts['puppet_confdir'] {
    fail('The puppetlabs/patching_as_code module depends on the puppetlabs/puppet_agent module, please add it to your setup!')
  }

  # Write local config file for unsafe processes
  file { "${facts['puppet_confdir']}/patching_unsafe_processes":
    ensure    => file,
    content   => $unsafe_process_list.join('\n'),
    show_diff => false
  }

  # Determine which patching module to use, this won't resolve when running as a plan but that's ok
  if defined('pe_patch') and $use_pe_patch {
    $pe_patch = true
  } else {
    $pe_patch = false
  }

  # Ensure the correct patching module is used and set patch_window/patch_group
  case $plan_patch_fact {
    undef: {
      # This is the base scenario, we need to select the patching module to use
      if $pe_patch {
        $patch_fact = 'pe_patch'
        if $classify_pe_patch {
          # Only classify pe_patch if $classify_pe_patch == true
          class { 'pe_patch':
            patch_group => join($patch_groups, ' '),
          }
        }
      } else {
        $patch_fact = 'os_patching'
        class { 'os_patching':
          patch_window => join($patch_groups, ' '),
        }
      }
    }
    'pe_patch': {
      # Received the patch_fact from a plan run, use it directly
      $patch_fact = 'pe_patch'
      class { 'pe_patch':
        patch_group => join($patch_groups, ' '),
      }
    }
    'os_patching': {
      # Received the patch_fact from a plan run, use it directly
      $patch_fact = 'os_patching'
      class { 'os_patching':
        patch_window => join($patch_groups, ' '),
      }
    }
    default: { fail('Unsupported value for plan_patch_fact parameter!') }
  }

  # Ensure yum-utils package is installed on RedHat/CentOS for needs-restarting utility
  if $facts['osfamily'] == 'RedHat' {
    ensure_packages('yum-utils')
  }

  # Determine if today is Patch Day for this node's $patch_groups
  if 'never' in $patch_groups {
    $bool_patch_day = false
    schedule { 'Patching as Code - Patch Window':
      period => 'never',
    }
    $_reboot = 'never'
    $active_pg = 'never'
  } elsif 'always' in $patch_groups {
    $bool_patch_day = true
    schedule { 'Patching as Code - Patch Window':
      range  => '00:00 - 23:59',
      repeat => 1440
    }
    $_reboot = 'ifneeded'
    $active_pg = 'always'
  } else {
    $pg_info = $patch_groups.map |$pg| {
      {
        'name'         => $pg,
        'is_patch_day' => patching_as_code::is_patchday(
                            $patch_schedule[$pg]['day_of_week'],
                            $patch_schedule[$pg]['count_of_week']
                          )
      }
    }
    $active_pg = $pg_info.reduce(undef) |$memo, $value| {
      if $value['is_patch_day'] == true { $value['name'] } else { $memo }
    }
    $bool_patch_day = type($active_pg,'generalized') ? {
      Type[String] => true,
      default => false
    }
    if $bool_patch_day {
      schedule { 'Patching as Code - Patch Window':
        range  => $patch_schedule[$active_pg]['hours'],
        repeat => $patch_schedule[$active_pg]['max_runs']
      }
      $_reboot = $patch_schedule[$active_pg]['reboot']
    }
  }

  # Write local state file for config reporting and reuse in plans
  file { 'patching_configuration.json':
    ensure    => file,
    path      => "${facts['puppet_vardir']}/../../facter/facts.d/patching_configuration.json",
    content   => to_json_pretty({
      patching_as_code_config => {
        allowlist              => $allowlist,
        blocklist              => $blocklist,
        enable_patching        => $enable_patching,
        patch_fact             => $patch_fact,
        patch_group            => $patch_groups,
        patch_schedule         => if $active_pg in ['always', 'never'] {
                                    { $active_pg => 'N/A' }
                                  } else {
                                    $patch_schedule.filter |$item| { $item[0] in $patch_groups }
                                  },
        post_patch_commands    => $post_patch_commands,
        pre_patch_commands     => $pre_patch_commands,
        pre_reboot_commands    => $pre_reboot_commands,
        patch_on_metered_links => $patch_on_metered_links,
        security_only          => $security_only,
        unsafe_process_list    => $unsafe_process_list,
      }
    }, false),
    show_diff => false
  }

  if $bool_patch_day {
    if $facts[$patch_fact] {
      $available_updates = $facts['kernel'] ? {
        'windows' =>  if $security_only == true {
                        unless $facts[$patch_fact]['missing_security_kbs'].empty {
                          $facts[$patch_fact]['missing_security_kbs']
                        } else {
                          $facts[$patch_fact]['missing_update_kbs']
                        }
                      } else {
                        $facts[$patch_fact]['missing_update_kbs']
                      },
        'Linux'   =>  if $security_only == true {
                        $facts[$patch_fact]['security_package_updates']
                      } else {
                        $facts[$patch_fact]['package_updates']
                      },
        default   => []
      }
    }
    else {
      $available_updates = []
    }

    case $allowlist.count {
      0: {
        $updates_to_install = $available_updates.filter |$item| { !($item in $blocklist) }
      }
      default: {
        $whitelisted_updates = $available_updates.filter |$item| { $item in $allowlist }
        $updates_to_install = $whitelisted_updates.filter |$item| { !($item in $blocklist) }
      }
    }

    $reboot = case $_reboot {
      'always':   {true}
      'never':    {false}
      'ifneeded': {true}
      default:    {false}
    }
    $reboot_if_needed = case $_reboot {
      'ifneeded': {true}
      default:    {false}
    }
    if $reboot {
      # Reboot the node first if a reboot is already pending
      case $facts['kernel'].downcase() {
        /(windows|linux)/: {
          reboot_if_pending {'Patching as Code':
            patch_window => 'Patching as Code - Patch Window',
            os           => $0
          }
        }
        default: {
          fail('Unsupported operating system for Patching as Code!')
        }
      }
    }
    anchor {'patching_as_code::start':}

    if ($updates_to_install.count > 0) and ($enable_patching == true) {
      if (($patch_on_metered_links == true) or (! $facts['metered_link'] == true)) and (! $facts['patch_unsafe_process_active'] == true) {
        case $facts['kernel'].downcase() {
          /(windows|linux)/: {
            # Run pre-patch commands if provided
            $pre_patch_commands.each | $cmd, $cmd_opts | {
              exec { "Patching as Code - Before patching - ${cmd}":
                *        => delete($cmd_opts, ['before', 'schedule', 'tag']),
                before   => Class["patching_as_code::${0}::patchday"],
                schedule => 'Patching as Code - Patch Window',
                tag      => ['patching_as_code_pre_patching']
              }
            }
            # Perform main patching run
            class { "patching_as_code::${0}::patchday":
              updates    => $updates_to_install,
              patch_fact => $patch_fact,
              require    => Anchor['patching_as_code::start']
            } -> notify {'Patching as Code - Update Fact':
              message  => "Patches installed, refreshing ${patch_fact} fact...",
              notify   => Exec["${patch_fact}::exec::fact"],
              schedule => 'Patching as Code - Patch Window',
            }
            if $reboot {
              # Reboot after patching (in later patch_reboot stage)
              class { 'patching_as_code::reboot':
                reboot_if_needed => $reboot_if_needed,
                schedule         => 'Patching as Code - Patch Window',
                stage            => patch_reboot
              }
              # Perform post-patching Execs
              $post_patch_commands.each | $cmd, $cmd_opts | {
                exec { "Patching as Code - After patching - ${cmd}":
                  *        => delete($cmd_opts, ['require', 'before', 'schedule', 'tag']),
                  require  => Class["patching_as_code::${0}::patchday"],
                  schedule => 'Patching as Code - Patch Window',
                  tag      => ['patching_as_code_post_patching']
                } -> Exec <| tag == 'patching_as_code_pre_reboot' |>
              }
              # Define pre-reboot Execs
              case $facts['kernel'].downcase() {
                'windows': {
                  $reboot_logic_provider = 'powershell'
                  $reboot_logic_onlyif   = $reboot_if_needed ? {
                    true  => "${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.ps1 | findstr -i True",
                    false => undef
                  }
                }
                'linux': {
                  $reboot_logic_provider = 'posix'
                  $reboot_logic_onlyif   = $reboot_if_needed ? {
                    true  => "/bin/sh ${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.sh | grep true",
                    false => undef
                  }
                }
                default: {
                  fail('Unsupported operating system for Patching as Code!')
                }
              }
              $pre_reboot_commands.each | $cmd, $cmd_opts | {
                exec { "Patching as Code - Before reboot - ${cmd}":
                  *        => delete($cmd_opts, ['provider', 'onlyif', 'unless', 'require', 'before', 'schedule', 'tag']),
                  provider => $reboot_logic_provider,
                  onlyif   => $reboot_logic_onlyif,
                  require  => Class["patching_as_code::${0}::patchday"],
                  schedule => 'Patching as Code - Patch Window',
                  tag      => ['patching_as_code_pre_reboot']
                }
              }
            } else {
              # Do not reboot after patching, just run post_patch commands if given
              $post_patch_commands.each | $cmd, $cmd_opts | {
                exec { "Patching as Code - After patching - ${cmd}":
                  *        => delete($cmd_opts, ['require', 'schedule', 'tag']),
                  require  => Class["patching_as_code::${0}::patchday"],
                  schedule => 'Patching as Code - Patch Window',
                  tag      => ['patching_as_code_post_patching']
                }
              }
            }
          }
          default: {
            fail('Unsupported operating system for Patching as Code!')
          }
        }
      } else {
        if $facts['metered_link'] == true {
          notice("Puppet is skipping installation of patches on ${trusted['certname']} \
          due to the current network link being metered.")
        }
        if $facts['patch_unsafe_process_active'] == true {
          notice("Puppet is skipping installation of patches on ${trusted['certname']} \
          because a process is active that is unsafe for patching.")
        }
      }
    }
  }
}
