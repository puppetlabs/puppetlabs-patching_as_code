# class patching_as_code::wu
class patching_as_code::wu () {
  file { 'C:\\Program Files\\WindowsPowerShell\\Modules\\PSWindowsUpdate':
    ensure             => directory,
    recurse            => true,
    source_permissions => ignore,
    source             => 'puppet:///modules/patching_as_code',
  }
  -> file { 'C:\\ProgramData\\InstalledUpdates':
    ensure             => directory,
    recurse            => true,
    source_permissions => ignore,
  }
}
