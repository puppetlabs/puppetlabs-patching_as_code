
Facter.add('patching_as_code') do
  setcode do
    last_run_file = "#{Facter.value(:puppet_vardir)}/../../${patch_fact}/patching_as_code_last_run"
    if File.exist?(last_run_file)
      last_run = File.read(last_run_file)
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
