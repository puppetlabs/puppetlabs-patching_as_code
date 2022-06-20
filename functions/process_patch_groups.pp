function patching_as_code::process_patch_groups(
){
  if 'never' in $patching_as_code::patch_groups {
    $bool_patch_day = false
    schedule { 'Patching as Code - Patch Window':
      period => 'never',
    }
    $reboot = 'never'
    $active_pg = 'never'
  } elsif 'always' in $patching_as_code::patch_groups {
    $bool_patch_day = true
    schedule { 'Patching as Code - Patch Window':
      range  => '00:00 - 23:59',
      repeat => 1440
    }
    $reboot = 'ifneeded'
    $active_pg = 'always'
  } else {
    $pg_info = $patching_as_code::patch_groups.map |$pg| {
      {
        'name'         => $pg,
        'is_patch_day' => patching_as_code::is_patchday(
                            $patching_as_code::patch_schedule[$pg]['day_of_week'],
                            $patching_as_code::patch_schedule[$pg]['count_of_week'],
                            $pg
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
        range  => $patching_as_code::patch_schedule[$active_pg]['hours'],
        repeat => $patching_as_code::patch_schedule[$active_pg]['max_runs']
      }
      $reboot = $patching_as_code::patch_schedule[$active_pg]['reboot']
    } else {
      $reboot = 'never'
    }
  }

  if $patching_as_code::high_priority_patch_group == 'never' {
    $bool_high_prio_patch_day = false
    schedule { 'Patching as Code - High Priority Patch Window':
      period => 'never',
    }
    $high_prio_reboot = 'never'
  } elsif $patching_as_code::high_priority_patch_group == 'always' {
    $bool_high_prio_patch_day = true
    schedule { 'Patching as Code - High Priority Patch Window':
      range  => '00:00 - 23:59',
      repeat => 1440
    }
    $high_prio_reboot = 'ifneeded'
  } else {
    $bool_high_prio_patch_day = patching_as_code::is_patchday(
      $patching_as_code::patch_schedule[$patching_as_code::high_priority_patch_group]['day_of_week'],
      $patching_as_code::patch_schedule[$patching_as_code::high_priority_patch_group]['count_of_week'],
      $patching_as_code::high_priority_patch_group
    )
    if $bool_high_prio_patch_day {
      schedule { 'Patching as Code - High Priority Patch Window':
        range  => $patching_as_code::patch_schedule[$patching_as_code::high_priority_patch_group]['hours'],
        repeat => $patching_as_code::patch_schedule[$patching_as_code::high_priority_patch_group]['max_runs']
      }
      $high_prio_reboot = $patching_as_code::patch_schedule[$patching_as_code::high_priority_patch_group]['reboot']
    } else {
      $high_prio_reboot = 'never'
    }
  }

  $result = {
    'is_patch_day'           => $bool_patch_day,
    'reboot'                 => $reboot,
    'active_pg'              => $active_pg,
    'is_high_prio_patch_day' => $bool_high_prio_patch_day,
    'high_prio_reboot'       => $high_prio_reboot,
  }
  $result
}
