
Facter.add('patching_as_code') do
  setcode do
    option1 = "#{Facter.value(:puppet_vardir)}/../../pe_patch/patching_as_code_last_run"
    option2 = "#{Facter.value(:puppet_vardir)}/../../os_patching/patching_as_code_last_run"
    if File.exist?(option1)
      last_run = File.read(option1)
      result = {}
      result['last_run'] = last_run
      result['days_since_last_run'] = 'Date.parse(last_run) - Date.now'
      result
    elsif File.exist?(option2)
      last_run = File.read(option2)
      result = {}
      result['last_run'] = last_run
      result['days_since_last_run'] = 'Date.parse(last_run) - Date.now'
      result
    else
      {
        'last_run' => '',
        'days_since_last_run' => 0
      }
    end
  end
end
