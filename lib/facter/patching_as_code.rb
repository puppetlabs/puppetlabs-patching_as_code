Facter.add('patching_as_code') do
  setcode do
    option1 = "#{Facter.value(:puppet_vardir)}/../../pe_patch/patching_as_code_last_run"
    option2 = "#{Facter.value(:puppet_vardir)}/../../os_patching/patching_as_code_last_run"
    if File.exist?(option1)
      last_run = JSON.parse(File.read(option1))
      result = {}
      result['last_patch_run']            = last_run['last_run']
      result['days_since_last_patch_run'] = (DateTime.now.to_date - DateTime.strptime(last_run['last_run'], '%Y-%m-%d %H:%M').to_date).to_i
      result['patches_installed']         = last_run['patches_installed']
      result['choco_patches_installed']   = last_run['choco_patches_installed']
      result
    elsif File.exist?(option2)
      last_run = JSON.parse(File.read(option2))
      result = {}
      result['last_patch_run']            = last_run['last_run']
      result['days_since_last_patch_run'] = (DateTime.now.to_date - DateTime.strptime(last_run['last_run'], '%Y-%m-%d %H:%M').to_date).to_i
      result['patches_installed']         = last_run['patches_installed']
      result['choco_patches_installed']   = last_run['choco_patches_installed']
      result
    else
      {
        'last_run' => '',
        'days_since_last_run' => 0,
        'patches_installed' => [],
        'choco_patches_installed' => []
      }
    end
  end
end
