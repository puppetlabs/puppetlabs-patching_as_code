Puppet::Type.newtype(:patch_package) do
  @doc = 'Define a package resource to patch'

  newparam(:name) do
    isnamevar
    desc 'Name of the package to patch'
  end

  newparam(:patch_window) do
    desc 'Puppet schedule to link package resource to'
  end

  newparam(:triggers, array_matching: :all) do
    desc 'Resources to notify after updating the package'

    munge do |values|
      values = [values] unless values.is_a? Array
      values
    end
  end

  # All parameters are required
  validate do
    [:name, :patch_window, :triggers].each do |param|
      raise Puppet::Error, "Required parameter missing: #{param}" unless @parameters[param]
    end
  end

  # See if the package to patch exists in the catalog
  # If package is found, update resource one-time for patching
  # If package is not found, create a one-time package resource
  def pre_run_check
    # Validate :triggers
    triggers = parameter(:triggers)
    triggers.value.each do |res|
      retrieve_resource_reference(res)
    rescue ArgumentError => e
      raise Puppet::Error, "Parameter triggers failed: #{e} at #{@file}:#{@line}"
    end

    package = self[:name]
    package_res = "Package[#{package}]"
    begin
      res = retrieve_resource_reference(package_res)
      package_in_catalog = true
    rescue ArgumentError
      package_in_catalog = false
    end

    if package_in_catalog
      if ['present', 'installed', 'latest'].include?(res['ensure'].to_s)
        Puppet.send('notice', "#{package_res} (managed) will be updated by Patching_as_code")
        catalog.resource(package_res)['ensure'] = 'latest'
        catalog.resource(package_res)['schedule'] = self[:patch_window]
        catalog.resource(package_res)['before'] = Array(catalog.resource(package_res)['before']) + ['Anchor[patching_as_code::patchday::end]']
        catalog.resource(package_res)['require'] = Array(catalog.resource(package_res)['require']) + ['Anchor[patching_as_code::patchday::start]']
        catalog.resource(package_res)['notify'] = Array(catalog.resource(package_res)['notify']) + triggers.value
      else
        Puppet.send('notice', "#{package_res} (managed) will not be updated by Patching_as_code, due to the package enforcing a specific version")
      end
    else
      Puppet.send('notice', "#{package_res} (unmanaged) will be updated by Patching_as_code")
      catalog.create_resource('package',
                              title: package,
                              ensure: 'latest',
                              schedule: self[:patch_window],
                              before: 'Anchor[patching_as_code::patchday::end]',
                              require: 'Anchor[patching_as_code::patchday::start]',
                              notify: triggers.value)
    end
  end

  def retrieve_resource_reference(res)
    case res
    when Puppet::Type      # rubocop:disable Lint/EmptyWhen
    when Puppet::Resource  # rubocop:disable Lint/EmptyWhen
    when String
      begin
        Puppet::Resource.new(res)
      rescue ArgumentError
        raise ArgumentError, "#{res} is not a valid resource reference"
      end
    else
      raise ArgumentError, "#{res} is not a valid resource reference"
    end

    resource = catalog.resource(res.to_s)

    raise ArgumentError, "#{res} is not in the catalog" unless resource

    resource
  end
end
