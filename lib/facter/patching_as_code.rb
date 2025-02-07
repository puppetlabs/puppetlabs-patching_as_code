Facter.add('patching_as_code') do
  confine kernel: ['windows', 'Linux']

  setcode do
    directory      = "#{Facter.value(:puppet_vardir)}/../../patching_as_code"
    file           = "#{directory}/last_run"
    high_prio_file = "#{directory}/high_prio_last_run"
    oldfile        = "#{Facter.value(:puppet_vardir)}/../../pe_patch/patching_as_code_last_run"
    begin
      # Migrate last_run file if still in old location
      if File.exist?(oldfile)
        Dir.mkdir(directory) unless Dir.exist?(directory)
        File.rename oldfile, file
      end
      last_run           = JSON.parse(File.read(file)) if File.exist?(file)
      high_prio_last_run = JSON.parse(File.read(high_prio_file)) if File.exist?(high_prio_file)
      result = {}
      if last_run.nil?
        result['last_patch_run']                        = ''
        result['days_since_last_patch_run']             = 0
        result['patches_installed_on_last_run']         = []
        result['choco_patches_installed_on_last_run']   = []
      else
        result['last_patch_run']                        = last_run['last_run']
        result['days_since_last_patch_run']             = (DateTime.now.to_date - DateTime.strptime(last_run['last_run'], '%Y-%m-%d %H:%M').to_date).to_i
        result['patches_installed_on_last_run']         = last_run['patches_installed']
        result['choco_patches_installed_on_last_run']   = last_run['choco_patches_installed']
      end
      if high_prio_last_run.nil?
        result['last_high_prio_patch_run']                      = ''
        result['days_since_last_high_prio_patch_run']           = 0
        result['patches_installed_on_last_high_prio_run']       = []
        result['choco_patches_installed_on_last_high_prio_run'] = []
      else
        result['last_high_prio_patch_run']                      = high_prio_last_run['last_run']
        result['days_since_last_high_prio_patch_run']           = (DateTime.now.to_date - DateTime.strptime(high_prio_last_run['last_run'], '%Y-%m-%d %H:%M').to_date).to_i
        result['patches_installed_on_last_high_prio_run']       = high_prio_last_run['patches_installed']
        result['choco_patches_installed_on_last_high_prio_run'] = high_prio_last_run['choco_patches_installed']
      end
      result
    rescue
      {
        'last_patch_run'                                => '',
        'days_since_last_patch_run'                     => 0,
        'patches_installed_on_last_run'                 => [],
        'choco_patches_installed_on_last_run'           => [],
        'last_high_prio_patch_run'                      => '',
        'days_since_last_high_prio_patch_run'           => 0,
        'patches_installed_on_last_high_prio_run'       => [],
        'choco_patches_installed_on_last_high_prio_run' => []
      }
    end
  end
end
