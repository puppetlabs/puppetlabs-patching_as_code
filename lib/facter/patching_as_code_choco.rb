
Facter.add('patching_as_code_choco') do
  confine kernel: 'windows'
  setcode do
    if Facter.fact(:patching_as_code_config) == nil
      {
        'package_update_count' => 0,
        'packages' => [],
        'pinned_packages' => []
      }
    elsif Facter.value(:patching_as_code_config)['patch_choco'] == true
      programdata = ENV['ProgramData']
      choco = "#{programdata}\\chocolatey\\bin\\choco.exe"
      output = if File.exist?(choco)
                 Facter::Util::Resolution.exec("#{choco} outdated -r").to_s.split("\n")
               else
                 ''
               end
      packages = []
      pinned = []
      # Determine Pinned packages (to be excluded from updating)
      output.each do |line|
        data = line.split('|')
        next if pinned.include? data[0].split('.')[0]

        pinned.push(data[0]) if data[3] == 'true'
      end
      # Determine packages to update
      output.each do |line|
        data = line.split('|')
        # Exclude subcomponents of packages
        next if pinned.include? data[0].split('.')[0]
        next if packages.include? data[0].split('.')[0]

        packages.push(data[0]) if data[3] == 'false'
      end
      result = {}
      result['package_update_count'] = packages.count
      result['packages'] = packages
      result['pinned_packages'] = pinned
      result
    else
      {
        'package_update_count' => 0,
        'packages' => [],
        'pinned_packages' => []
      }
    end
  end
end
