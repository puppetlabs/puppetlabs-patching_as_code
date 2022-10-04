# Class: patching_as_code::reboot
#
# @summary
#   This class gets called by init.pp to reboot the node. You can use Hiera to set a different default for the reboot_delay if desired.
# @param [Boolean] reboot_if_needed
#   Only reboot the node if a system reboot is pending. This parameter is passed automatically from init.pp
# @param [Integer] reboot_delay
#   Time in seconds to delay the reboot by, defaults to 2 minutes.
#   To override for patching, specify an alternate value by setting the patching_as_code::reboot::reboot_delay parameter in Hiera.
class patching_as_code::reboot (
  Boolean $reboot_if_needed = true,
  Integer $reboot_delay = 120
) {
  $reboot_delay_min = round($reboot_delay / 60)
  if $reboot_if_needed {
    # Define an Exec to perform the reboot shortly after the Puppet run completes
    case $facts['kernel'].downcase() {
      'windows': {
        $reboot_logic_provider = 'powershell'
        $reboot_logic_cmd      = "& shutdown /r /t ${reboot_delay} /c \"Patching_as_code: Rebooting system due to a pending reboot after patching\" /d p:2:17" # lint:ignore:140chars 
        $reboot_logic_onlyif   = "${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.ps1 | findstr -i True"
      }
      'linux': {
        $reboot_logic_provider = 'posix'
        $reboot_logic_cmd      = "/sbin/shutdown -r +${reboot_delay_min}"
        $reboot_logic_onlyif   = "/bin/sh ${facts['puppet_vardir']}/lib/patching_as_code/pending_reboot.sh | grep true"
      }
      default: {
        fail('Unsupported operating system for Patching as Code!')
      }
    }
    exec { 'Patching as Code - Patch Reboot':
      command   => $reboot_logic_cmd,
      onlyif    => $reboot_logic_onlyif,
      provider  => $reboot_logic_provider,
      logoutput => true,
      schedule  => 'Patching as Code - Patch Window',
    }
  } else {
    # Reboot as part of this Puppet run
    reboot { 'Patching as Code - Patch Reboot':
      apply    => 'immediately',
      schedule => 'Patching as Code - Patch Window',
      timeout  => $reboot_delay,
    }
    notify { 'Patching as Code - Performing OS reboot':
      notify   => Reboot['Patching as Code - Patch Reboot'],
      schedule => 'Patching as Code - Patch Window',
    }
  }
}
