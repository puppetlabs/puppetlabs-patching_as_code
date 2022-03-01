Facter.add('patching_as_code') do
  setcode do
    file = "#{Facter.value(:puppet_vardir)}/../../patching_as_code/last_run"
    begin
      if File.exist?(file)
        last_run = JSON.parse(File.read(option1))
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
