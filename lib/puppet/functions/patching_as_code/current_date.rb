Puppet::Functions.create_function(:'patching_as_code::current_date') do
  dispatch :current_date do
  end

  def current_date
    Date.now
  end
end
