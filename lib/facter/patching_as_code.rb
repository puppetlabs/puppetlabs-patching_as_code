Facter.add('patching_as_code') do
  setcode do
    directory = "#{Facter.value(:puppet_vardir)}/../../patching_as_code"
    file = "#{directory}/last_run"
    begin
      # Migrate fact if still in old location
      if File.exist?("#{directory}/../pe_patch/patching_as_code_last_run")
        Dir.mkdir(directory) unless Dir.exist?(directory)
        File.rename "#{directory}/../pe_patch/patching_as_code_last_run", file
      end
      if File.exist?(file)
        last_run = JSON.parse(File.read(file))
        result = {}
        result['last_patch_run']            = last_run['last_run']
        result['days_since_last_patch_run'] = (DateTime.now.to_date - DateTime.strptime(last_run['last_run'], '%Y-%m-%d %H:%M').to_date).to_i
        result['patches_installed_on_last_run']         = last_run['patches_installed']
        result['choco_patches_installed_on_last_run']   = last_run['choco_patches_installed']
        result
      else
        {
          'last_patch_run' => '',
          'days_since_last_patch_run' => 0,
          'patches_installed_on_last_run' => [],
          'choco_patches_installed_on_last_run' => []
        }
      end
    rescue
      {
        'last_patch_run' => '',
        'days_since_last_patch_run' => 0,
        'patches_installed_on_last_run' => [],
        'choco_patches_installed_on_last_run' => []
      }
    end
  end
end
