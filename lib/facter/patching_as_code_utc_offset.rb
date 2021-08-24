require 'time'

Facter.add('patching_as_code_utc_offset') do
  (Time.now.utc_offset / 3600).to_f
end
