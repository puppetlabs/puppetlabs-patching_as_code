# define patching_as_code::kb
# 
# @summary
#   This define gets called by init.pp to install Windows KB patches.
# @param [String] ensure
#   When set to 'enabled' or 'present', will allow this resource to be applied. Removing updates is currently not supported.
# @param [String] kb
#   Name of the KB patch to install.
# @param [Optional[String]] maintwindow
#   Name of the patch window to use for installing the patch.
define patching_as_code::kb (
  String $ensure                = 'enabled',
  String $kb                    = $name,
  Optional[String] $maintwindow = undef
) {
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
            schedule  => $maintwindow,
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
            schedule  => $maintwindow,
          }
        }
      }
    }
    default: {
      fail('Invalid ensure option!\n')
    }
  }
}
