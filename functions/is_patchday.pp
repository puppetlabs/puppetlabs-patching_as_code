function patching_as_code::is_patchday(
  Enum['Any','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'] $day_of_week,
  Variant[Integer, Array] $week_iteration
){
  $timestamp    = Timestamp()
  $year         = $timestamp.strftime('%Y')
  $month        = $timestamp.strftime('%m')
  $weekday      = Integer($timestamp.strftime('%u'))
  $dayofmonth   = Integer($timestamp.strftime('%e'))
  $startofmonth = Timestamp("${year}-${month}-01", '%Y-%m-%e')
  $som_weekday  = Integer($startofmonth.strftime('%u'))
  $day_number = $day_of_week ? {
    'Any'       => $weekday,
    'Monday'    => 1,
    'Tuesday'   => 2,
    'Wednesday' => 3,
    'Thursday'  => 4,
    'Friday'    => 5,
    'Saturday'  => 6,
    'Sunday'    => 7
  }

  # Calculate first occurence of same weekday
  if $day_number - $som_weekday < 0 {
    $firstocc = 1 + 7 + $day_number - $som_weekday
  } else {
    $firstocc = 1 + $day_number - $som_weekday
  }

  # Calculate dates of valid patch days
  case type($week_iteration, 'generalized') {
    Type[Integer]: {
      $patchdays = Array($firstocc + (( $week_iteration - 1 ) * 7 ), true)
    }
    Type[Array[Integer]]: {
      $patchdays = $week_iteration.map |$week| { $firstocc + (( $week - 1 ) * 7 ) }
    }
    default: {
      fail('The count_of_week parameter of the patch_schedule must be configured as an integer or an array of integers!')
    }
  }

  # Return true if today is a patch day
  if $dayofmonth in $patchdays {
    true
  } else {
    false
  }

}
