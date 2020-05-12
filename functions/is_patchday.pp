function patching_as_code::is_patchday(
  Enum['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'] $day_of_week,
  Integer $week_iteration
){
  $day_number = $day_of_week ? {
    'Monday'    => 1,
    'Tuesday'   => 2,
    'Wednesday' => 3,
    'Thursday'  => 4,
    'Friday'    => 5,
    'Saturday'  => 6,
    'Sunday'    => 7
  }
  $timestamp    = Timestamp()
  $year         = $timestamp.strftime('%Y')
  $month        = $timestamp.strftime('%m')
  $dayofmonth   = Integer($timestamp.strftime('%e'))
  $startofmonth = Timestamp("${year}-${month}-01", '%Y-%m-%e')
  $som_weekday  = Integer($startofmonth.strftime('%u'))

  # Calculate first occurence of same weekday
  if $day_number - $som_weekday <= 0 {
    $firstocc = 1 + 7 + $day_number - $som_weekday
  } else {
    $firstocc = 1 + $day_number - $som_weekday
  }

  # Calculate date of patch day
  $patchday = $firstocc + (( $week_iteration - 1 ) * 7 )

  # Return true if today is patch day
  if $patchday == $dayofmonth {
    true
  } else {
    false
  }

}
