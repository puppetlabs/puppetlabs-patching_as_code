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
# @param [Array] blocklist_choco
#   List of Chocolatey updates to block from installing
# @param [Array] allowlist_choco
#   List of Chocolatey updates that are allowed to be installed. Any Chocolatey updates not on this list get blocked.
# @param [String] high_priority_patch_group
#   Name of the high_priority_patch_group for this node. Must match a patch group in `$patch_schedule`
#   This patch schedule will only be used for patches in the `$high_priority_list`.
# @param [Array] high_priority_list
#   List of updates to install on the patch schedule set by `$high_priority_patch_group`.
# @param [Array] high_priority_list_choco
#   List of Chocolatey updates to install on the patch schedule set by `$high_priority_patch_group`.
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
# @param [Optional[Boolean]] fact_upload
#   How os_patching/pe_patch handles changes to fact cache. Defaults to true.
#   When true (default), `puppet fact upload` occurs as expected
#   When false, changes to fact cache are not uploaded
# @param [Optional[String]] plan_patch_fact
#   Reserved parameter for running `patching_as_code` via a Plan (future functionality).
# @param [Optional[Boolean]] enable_patching
#   Controls if `patching_as_code` is allowed to install any updates.
#   Can be used to disable patching with a single override.
# @param [Optional[Boolean]] security_only
#   Install only security updates. Requires latest version of Puppet Enterprise to work on Windows.
#   When using `os_patching`, security updates can only be applied to Linux.
#   If patching of Chocolatey packages is enabled, those packages will still update even if
#   `security_only` is set to `true`.
# @param [Optional[Boolean]] high_priority_only
#   Only allow updates from the `$high_priority_list` to be installed. Enabling this option will prevent
#   regular patches from being installed, and will skip a pending reboot at the beginning of the patch
#   run if a pending reboot is detected. A pending reboot may still happen at the end of the patch run,
#   as long as the patch schedule set by `$high_priority_patch_group` allows reboots to occur.
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
  Array                         $blocklist_choco,
  Array                         $allowlist_choco,
  String                        $high_priority_patch_group,
  Array                         $high_priority_list,
  Array                         $high_priority_list_choco,
  Array                         $unsafe_process_list,
  Hash                          $pre_patch_commands,
  Hash                          $post_patch_commands,
  Hash                          $pre_reboot_commands,
  Optional[Boolean]             $fact_upload = true,
  Optional[String]              $plan_patch_fact = undef,
  Optional[Boolean]             $enable_patching = true,
  Optional[Boolean]             $security_only = false,
  Optional[Boolean]             $high_priority_only = false,
  Optional[Boolean]             $patch_choco = false,
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

  # Verify if the $high_priority_patch_group points to a valid patch schedule
  unless $patch_schedule[$high_priority_patch_group] or $high_priority_patch_group in ['always', 'never'] {
    fail("High Priority Patch group ${high_priority_patch_group} is not valid as no associated schedule was found!
    Ensure the patching_as_code::patch_schedule parameter contains a schedule for this patch group.")
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
            fact_upload => $fact_upload,
          }
        }
      } else {
        $patch_fact = 'os_patching'
        class { 'os_patching':
          patch_window => join($patch_groups, ' '),
          fact_upload  => $fact_upload,
        }
      }
    }
    'pe_patch': {
      # Received the patch_fact from a plan run, use it directly
      $patch_fact = 'pe_patch'
      class { 'pe_patch':
        patch_group => join($patch_groups, ' '),
        fact_upload => $fact_upload,
      }
    }
    'os_patching': {
      # Received the patch_fact from a plan run, use it directly
      $patch_fact = 'os_patching'
      class { 'os_patching':
        patch_window => join($patch_groups, ' '),
        fact_upload  => $fact_upload,
      }
    }
    default: { fail('Unsupported value for plan_patch_fact parameter!') }
  }

  # Ensure yum-utils package is installed on RedHat/CentOS for needs-restarting utility
  if $facts['osfamily'] == 'RedHat' {
    ensure_packages('yum-utils')
  }

  # Determine if today is Patch Day for this node's $patch_groups and $high_priority_patch_group
  $result = patching_as_code::process_patch_groups()
  $bool_patch_day           = $result['is_patch_day']
  $_reboot                  = $result['reboot']
  $_high_prio_reboot        = $result['high_prio_reboot']
  $active_pg                = $result['active_pg']
  $bool_high_prio_patch_day = $result['is_high_prio_patch_day']

  # Write local state file for config reporting and reuse in plans
  file { 'patching_configuration.json':
    ensure    => file,
    path      => "${facts['puppet_vardir']}/../../facter/facts.d/patching_configuration.json",
    content   => to_json_pretty({
      patching_as_code_config => {
        allowlist                 => $allowlist,
        blocklist                 => $blocklist,
        high_priority_list        => $high_priority_list,
        allowlist_choco           => $allowlist_choco,
        blocklist_choco           => $blocklist_choco,
        high_priority_list_choco  => $high_priority_list_choco,
        enable_patching           => $enable_patching,
        patch_fact                => $patch_fact,
        patch_group               => $patch_groups,
        patch_schedule            => if $active_pg in ['always', 'never'] {
                                    { $active_pg => 'N/A' }
                                  } else {
                                    $patch_schedule.filter |$item| { $item[0] in $patch_groups }
                                  },
        high_priority_patch_group => $high_priority_patch_group,
        post_patch_commands       => $post_patch_commands,
        pre_patch_commands        => $pre_patch_commands,
        pre_reboot_commands       => $pre_reboot_commands,
        patch_on_metered_links    => $patch_on_metered_links,
        security_only             => $security_only,
        patch_choco               => $patch_choco,
        unsafe_process_list       => $unsafe_process_list,
      }
    }, false),
    show_diff => false
  }

  if $bool_patch_day or $bool_high_prio_patch_day {
    if $facts[$patch_fact] {
      $available_updates = $facts['kernel'] ? {
        'windows' =>  if $bool_patch_day and $security_only and !$high_priority_only {
                        unless $facts[$patch_fact]['missing_security_kbs'].empty {
                          $facts[$patch_fact]['missing_security_kbs']
                        } else {
                          $facts[$patch_fact]['missing_update_kbs']
                        }
                      } elsif $bool_patch_day and !$high_priority_only {
                        $facts[$patch_fact]['missing_update_kbs']
                      } else {
                        []
                      },
        'Linux'   =>  if $bool_patch_day and $security_only and !$high_priority_only{
                        $facts[$patch_fact]['security_package_updates']
                      } elsif $bool_patch_day and !$high_priority_only{
                        $facts[$patch_fact]['package_updates']
                      } else {
                        []
                      },
        default   => []
      }
      $choco_updates = $facts['kernel'] ? {
        'windows' =>  if $bool_patch_day and $patch_choco and !$high_priority_only {
                        if $facts['patching_as_code_choco'] {
                          $facts['patching_as_code_choco']['packages']
                        } else {
                          []
                        }
                      } else {
                        []
                      },
        default   => []
      }
      $high_prio_updates = $facts['kernel'] ? {
        'windows' =>  if $bool_high_prio_patch_day {
                        $facts[$patch_fact]['missing_update_kbs'].filter |$item| { $item in $high_priority_list }
                      } else {
                        []
                      },
        'Linux'   =>  if $bool_high_prio_patch_day {
                        $facts[$patch_fact]['package_updates'].filter |$item| { $item in $high_priority_list }
                      } else {
                        []
                      },
        default   => []
      }
      $high_prio_updates_choco = $facts['kernel'] ? {
        'windows' =>  if $bool_high_prio_patch_day and $patch_choco == true {
                        if $facts['patching_as_code_choco'] {
                          $facts['patching_as_code_choco']['packages'].filter |$item| { $item in $high_priority_list_choco }
                        } else {
                          []
                        }
                      } else {
                        []
                      },
        default   => []
      }
    }
    else {
      $available_updates = []
      $choco_updates = []
      $high_prio_updates = []
      $high_prio_updates_choco = []
    }

    case $allowlist.count {
      0: {
        $_updates_to_install          = $available_updates.filter |$item| { !($item in $blocklist) }
        $high_prio_updates_to_install = $high_prio_updates.filter |$item| { !($item in $blocklist) }
        if ($bool_patch_day and $bool_high_prio_patch_day) {
          $updates_to_install = $_updates_to_install.filter |$item| { !($item in $high_prio_updates_to_install) }
        } else {
          $updates_to_install = $_updates_to_install
        }
      }
      default: {
        $whitelisted_updates          =   $available_updates.filter |$item| { $item in $allowlist }
        $_updates_to_install          = $whitelisted_updates.filter |$item| { !($item in $blocklist) }
        $high_prio_updates_to_install =   $high_prio_updates.filter |$item| { !($item in $blocklist) }
        if ($bool_patch_day and $bool_high_prio_patch_day) {
          $updates_to_install = $_updates_to_install.filter |$item| { !($item in $high_prio_updates_to_install) }
        } else {
          $updates_to_install = $_updates_to_install
        }
      }
    }

    case $allowlist_choco.count {
      0: {
        $_choco_updates_to_install          =           $choco_updates.filter |$item| { !($item in $blocklist_choco) }
        $high_prio_choco_updates_to_install = $high_prio_updates_choco.filter |$item| { !($item in $blocklist_choco) }
        if ($bool_patch_day and $bool_high_prio_patch_day) {
          $choco_updates_to_install = $_choco_updates_to_install.filter |$item| { !($item in $high_prio_choco_updates_to_install) }
        } else {
          $choco_updates_to_install = $_choco_updates_to_install
        }
      }
      default: {
        $whitelisted_choco_updates          =             $choco_updates.filter |$item| { $item in $allowlist_choco }
        $_choco_updates_to_install          = $whitelisted_choco_updates.filter |$item| { !($item in $blocklist_choco) }
        $high_prio_choco_updates_to_install =   $high_prio_updates_choco.filter |$item| { !($item in $blocklist_choco) }
        if ($bool_patch_day and $bool_high_prio_patch_day) {
          $choco_updates_to_install = $_choco_updates_to_install.filter |$item| { !($item in $high_prio_choco_updates_to_install) }
        } else {
          $choco_updates_to_install = $_choco_updates_to_install
        }
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
    $high_prio_reboot = case $_high_prio_reboot {
      'always':   {true}
      'never':    {false}
      'ifneeded': {true}
      default:    {false}
    }
    $high_prio_reboot_if_needed = case $_high_prio_reboot {
      'ifneeded': {true}
      default:    {false}
    }

    # Perform pending reboots pre-patching, except if this is a high prio only run
    if $enable_patching and !$high_priority_only {
      if $reboot and $bool_patch_day {
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
      if $high_prio_reboot and $bool_high_prio_patch_day and
      ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0){
        # Reboot the node first if a reboot is already pending
        case $facts['kernel'].downcase() {
          /(windows|linux)/: {
            reboot_if_pending {'Patching as Code High Priority':
              patch_window => 'Patching as Code - High Priority Patch Window',
              os           => $0
            }
          }
          default: {
            fail('Unsupported operating system for Patching as Code!')
          }
        }
      }
    }
    anchor {'patching_as_code::start':}

    if ($updates_to_install.count + $choco_updates_to_install.count +
    $high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) and
    ($enable_patching == true) {
      if (($patch_on_metered_links == true) or (! $facts['metered_link'] == true)) and (! $facts['patch_unsafe_process_active'] == true) {
        case $facts['kernel'].downcase() {
          /(windows|linux)/: {
            # Run pre-patch commands if provided
            if ($updates_to_install.count + $choco_updates_to_install.count > 0) {
              $pre_patch_commands.each | $cmd, $cmd_opts | {
                exec { "Patching as Code - Before patching - ${cmd}":
                  *        => delete($cmd_opts, ['before', 'schedule', 'tag']),
                  before   => Class["patching_as_code::${0}::patchday"],
                  schedule => 'Patching as Code - Patch Window',
                  tag      => ['patching_as_code_pre_patching']
                }
              }
            }
            if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) {
              $pre_patch_commands.each | $cmd, $cmd_opts | {
                exec { "Patching as Code - Before patching (High Priority) - ${cmd}":
                  *        => delete($cmd_opts, ['before', 'schedule', 'tag']),
                  before   => Class["patching_as_code::${0}::patchday"],
                  schedule => 'Patching as Code - High Priority Patch Window',
                  tag      => ['patching_as_code_pre_patching']
                }
              }
            }
            # Perform main patching run
            $patch_refresh_actions = $fact_upload ? {
              true  => [ Exec["${patch_fact}::exec::fact"], Exec["${patch_fact}::exec::fact_upload"] ],
              false => Exec["${patch_fact}::exec::fact"]
            }
            class { "patching_as_code::${0}::patchday":
              updates                 => $updates_to_install.unique,
              choco_updates           => $choco_updates_to_install.unique,
              high_prio_updates       => $high_prio_updates_to_install.unique,
              high_prio_choco_updates => $high_prio_choco_updates_to_install.unique,
              require                 => Anchor['patching_as_code::start']
            } -> file {"${facts['puppet_vardir']}/../../patching_as_code":
              ensure => directory
            }
            if ($updates_to_install.count + $choco_updates_to_install.count > 0) {
              file {'Patching as Code - Save Patch Run Info':
                ensure    => file,
                path      => "${facts['puppet_vardir']}/../../patching_as_code/last_run",
                show_diff => false,
                content   => Deferred('patching_as_code::last_run',[
                  $updates_to_install,
                  $choco_updates_to_install
                ]),
                schedule  => 'Patching as Code - Patch Window',
                require   => File["${facts['puppet_vardir']}/../../patching_as_code"]
              } -> notify {'Patching as Code - Update Fact':
                message  => 'Patches installed, refreshing patching facts...',
                notify   => $patch_refresh_actions,
                schedule => 'Patching as Code - Patch Window',
              }
            }
            if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) {
              file {'Patching as Code - Save High Priority Patch Run Info':
                ensure    => file,
                path      => "${facts['puppet_vardir']}/../../patching_as_code/high_prio_last_run",
                show_diff => false,
                content   => Deferred('patching_as_code::high_prio_last_run',[
                  $high_prio_updates_to_install,
                  $high_prio_choco_updates_to_install
                ]),
                schedule  => 'Patching as Code - High Priority Patch Window',
                require   => File["${facts['puppet_vardir']}/../../patching_as_code"]
              } -> notify {'Patching as Code - Update Fact (High Priority)':
                message  => 'Patches installed, refreshing patching facts...',
                notify   => $patch_refresh_actions,
                schedule => 'Patching as Code - High Priority Patch Window',
              }
            }
            if $reboot or $high_prio_reboot {
              # Reboot after patching (in later patch_reboot stage)
              if ($updates_to_install.count + $choco_updates_to_install.count > 0) and $reboot {
                class { 'patching_as_code::reboot':
                  reboot_if_needed => $reboot_if_needed,
                  schedule         => 'Patching as Code - Patch Window',
                  stage            => patch_reboot
                }
              }
              if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) and $high_prio_reboot {
                class { 'patching_as_code::high_prio_reboot':
                  reboot_if_needed => $high_prio_reboot_if_needed,
                  schedule         => 'Patching as Code - High Priority Patch Window',
                  stage            => patch_reboot
                }
              }
              # Perform post-patching Execs
              if ($updates_to_install.count + $choco_updates_to_install.count > 0) and $reboot {
                $post_patch_commands.each | $cmd, $cmd_opts | {
                  exec { "Patching as Code - After patching - ${cmd}":
                    *        => delete($cmd_opts, ['require', 'before', 'schedule', 'tag']),
                    require  => Class["patching_as_code::${0}::patchday"],
                    schedule => 'Patching as Code - Patch Window',
                    tag      => ['patching_as_code_post_patching']
                  } -> Exec <| tag == 'patching_as_code_pre_reboot' |>
                }
              }
              if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) and $high_prio_reboot {
                $post_patch_commands.each | $cmd, $cmd_opts | {
                  exec { "Patching as Code - After patching (High Priority) - ${cmd}":
                    *        => delete($cmd_opts, ['require', 'before', 'schedule', 'tag']),
                    require  => Class["patching_as_code::${0}::patchday"],
                    schedule => 'Patching as Code - High Priority Patch Window',
                    tag      => ['patching_as_code_post_patching']
                  } -> Exec <| tag == 'patching_as_code_pre_reboot' |>
                }
              }
              # Define pre-reboot Execs
              case $facts['kernel'].downcase() {
                'windows': {
                  $reboot_logic_provider = 'powershell'
                  $reboot_logic_onlyif   = $reboot_if_needed ? {
                    true  => "${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.ps1 | findstr -i True",
                    false => undef
                  }
                  $reboot_logic_onlyif_high_prio = $high_prio_reboot_if_needed ? {
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
                  $reboot_logic_onlyif_high_prio = $high_prio_reboot_if_needed ? {
                    true  => "/bin/sh ${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.sh | grep true",
                    false => undef
                  }
                }
                default: {
                  fail('Unsupported operating system for Patching as Code!')
                }
              }
              if ($updates_to_install.count + $choco_updates_to_install.count > 0) and $reboot {
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
              }
              if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) and $high_prio_reboot {
                $pre_reboot_commands.each | $cmd, $cmd_opts | {
                  exec { "Patching as Code - Before reboot (High Priority) - ${cmd}":
                    *        => delete($cmd_opts, ['provider', 'onlyif', 'unless', 'require', 'before', 'schedule', 'tag']),
                    provider => $reboot_logic_provider,
                    onlyif   => $reboot_logic_onlyif_high_prio,
                    require  => Class["patching_as_code::${0}::patchday"],
                    schedule => 'Patching as Code - High Priority Patch Window',
                    tag      => ['patching_as_code_pre_reboot']
                  }
                }
              }
            } else {
              # Do not reboot after patching, just run post_patch commands if given
              if ($updates_to_install.count + $choco_updates_to_install.count > 0) {
                $post_patch_commands.each | $cmd, $cmd_opts | {
                  exec { "Patching as Code - After patching - ${cmd}":
                    *        => delete($cmd_opts, ['require', 'schedule', 'tag']),
                    require  => Class["patching_as_code::${0}::patchday"],
                    schedule => 'Patching as Code - Patch Window',
                    tag      => ['patching_as_code_post_patching']
                  }
                }
              }
              if ($high_prio_updates_to_install.count + $high_prio_choco_updates_to_install.count > 0) {
                $post_patch_commands.each | $cmd, $cmd_opts | {
                  exec { "Patching as Code - After patching (High Priority)- ${cmd}":
                    *        => delete($cmd_opts, ['require', 'schedule', 'tag']),
                    require  => Class["patching_as_code::${0}::patchday"],
                    schedule => 'Patching as Code - High Priority Patch Window',
                    tag      => ['patching_as_code_post_patching']
                  }
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
