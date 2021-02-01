# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:enable Style/FrozenStringLiteralComment
Puppet::Type.newtype(:reboot_if_pending) do
  @doc = 'Perform a clean reboot if it was pending before this agent run'

  newparam(:name) do
    isnamevar
    desc 'Name of this resource (has no function)'
  end

  newparam(:patch_window) do
    desc 'Puppet schedule to link the reboot resource to'
  end

  newparam(:os) do
    desc 'OS type from kernel fact'
  end

  # All parameters are required
  validate do
    [:name, :patch_window, :os].each do |param|
      raise Puppet::Error, "Required parameter missing: #{param}" unless @parameters[param]
    end
  end

  # Add a reboot resource to the catalog if a pending reboot is detected
  def pre_run_check
    # Check for pending reboots
    pending_reboot = false
    kernel = parameter(:os).value.downcase
    case kernel
    when 'windows'
      sysroot = ENV['SystemRoot']
      powershell = "#{sysroot}\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
      # get the script path relative to the Puppet Type
      checker_script = File.join(
        __dir__,
        '..',
        '..',
        'patching_as_code',
        'pending_reboot.ps1',
      )
      pending_reboot = Puppet::Util::Execution.execute("#{powershell} -ExecutionPolicy Unrestricted -File #{checker_script}").chomp.to_s.downcase == 'true'
    when 'linux'
      puts 'Not yet implemented'
    else
      raise Puppet::Error, "Patching_as_code - Unsupported Operating System type: #{kernel}"
    end
    return unless pending_reboot

    Puppet.send('notice', 'Patching_as_code - Pending OS reboot detected, node will reboot at start of patch window today')
    catalog.add_resource(Puppet::Type.type('reboot').new(
                           title: 'Patching as Code - Pending OS reboot',
                           apply: 'immediately',
                           schedule: parameter(:patch_window).value,
                           before: "Class[patching_as_code::#{kernel}::patchday]",
                         ))

    puts catalog.resource('Reboot[Patching as Code - Pending OS reboot]')
    puts catalog.resource('Reboot[Patching as Code - Pending OS reboot]')['schedule']
    puts catalog.resource('Reboot[Patching as Code - Pending OS reboot]')['before']
    # if package_in_catalog
    #   if ['present', 'installed', 'latest'].include?(res['ensure'].to_s)
    #     Puppet.send('notice', "#{package_res} (managed) will be updated by Patching_as_code")
    #     catalog.resource(package_res)['ensure'] = 'latest'
    #     catalog.resource(package_res)['schedule'] = self[:patch_window]
    #     catalog.resource(package_res)['require'] = Array(catalog.resource(package_res)['require']) + cache_clean.value
    #     catalog.resource(package_res)['notify'] = Array(catalog.resource(package_res)['notify']) + triggers.value
    #   else
    #     Puppet.send('notice', "#{package_res} (managed) will not be updated by Patching_as_code, due to the package enforcing a specific version")
    #   end
    # else
    #   Puppet.send('notice', "#{package_res} (unmanaged) will be updated by Patching_as_code")
    #   catalog.add_resource(Puppet::Type.type('package').new(
    #                          title: package,
    #                          ensure: 'latest',
    #                          schedule: self[:patch_window],
    #                          require: cache_clean.value,
    #                          notify: triggers.value,
    #                        ))
    # end
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
