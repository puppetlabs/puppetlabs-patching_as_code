# Class: patching_as_code::reboot
#
#
class patching_as_code::reboot(
  Boolean $reboot_if_needed = true,
  Integer $reboot_delay = 120
) {
  $reboot_when = $reboot_if_needed ? {
    true  => pending,
    false => refreshed
  }

  reboot { 'Patching as Code - Patch Reboot':
    apply    => 'immediately',
    schedule => 'Patching as Code - Patch Window',
    timeout  => $reboot_delay,
    when     => $reboot_when
  }

  unless $reboot_if_needed {
    notify {'Patching as Code - Performing OS reboot':
      notify => Reboot['Patching as Code - Patch Reboot']
    }
  }
}
