
Facter.add('patching_as_code_choco') do
  confine kernel: 'windows'
  setcode do
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
      pinned.push(data[0]) if data[3] == 'true'
    end
    # Determine packages to update
    output.each do |line|
      data = line.split('|')
      # Exclude subcomponents of pinned packages
      next if pinned.include? data[0].split('.')[0]

      packages.push(data[0]) if data[3] == 'false'
    end
    result = {}
    result['package_update_count'] = packages.count
    result['packages'] = packages
    result['pinned_packages'] = pinned
    result
  end
end
