require 'time'

Puppet::Functions.create_function(:'patching_as_code::get_srv_utc_offset') do
  dispatch :get_srv_utc_offset do
  end

  def get_srv_utc_offset
    (Time.now.utc_offset / 3600).to_f
  end
end
