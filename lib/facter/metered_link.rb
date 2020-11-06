
Facter.add('metered_link') do
  confine kernel: 'windows'
  setcode do
    sysroot = ENV['SystemRoot']
    powershell = "#{sysroot}\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
    # get the script path relative to facter Ruby program
    checker_script = File.join(
      File.expand_path(File.dirname(__FILE__)),
      '..',
      'patching_as_code',
      'metered_link.ps1',
    )
    Facter::Util::Resolution.exec("#{powershell} -ExecutionPolicy Unrestricted -File #{checker_script}").to_s == 'true'
  end
end
