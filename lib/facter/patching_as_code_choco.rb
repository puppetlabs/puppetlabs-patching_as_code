
Facter.add('patching_as_code_choco') do
  confine kernel: 'windows'
  setcode do
    programdata = ENV['ProgramData']
    choco = "#{programdata}\\chocolatey\\bin\\choco.exe"
    output = Facter::Util::Resolution.exec("#{choco} outdated -r").to_s.split("\n")
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
    packages
  end
end
