# define patching_as_code::kb
define patching_as_code::kb (
  $ensure      = 'enabled',
  $kb          = $name,
  $maintwindow = undef
){
  require patching_as_code::wu

  case $ensure {
    'enabled', 'present': {
      case $kb {
        'KB890830', 'KB2267602', 'KB2461484', 'KB4052623': {
          #Don't skip recurring monthly updates (Malicious Software Removal Tool, Windows Defender/SCEP updates)
          exec { "Install ${kb}":
            command   => template('patching_as_code/install_kb.ps1.erb'),
            provider  => 'powershell',
            timeout   => 14400,
            logoutput => true,
            schedule  => $maintwindow
          }
        }
        default: {
          #Run update if it hasn't successfully run before
          exec { "Install ${kb}":
            command   => template('patching_as_code/install_kb.ps1.erb'),
            creates   => "C:\\ProgramData\\InstalledUpdates\\${kb}.flg",
            provider  => 'powershell',
            timeout   => 14400,
            logoutput => true,
            schedule  => $maintwindow
          }
        }
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
