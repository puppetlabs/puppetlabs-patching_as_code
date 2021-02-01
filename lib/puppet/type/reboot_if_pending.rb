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

  newparam(:patchday_class) do
    desc 'Name of the patchday class'
  end

  # All parameters are required
  validate do
    [:name, :patch_window, :patchday_class].each do |param|
      raise Puppet::Error, "Required parameter missing: #{param}" unless @parameters[param]
    end
  end

  # See if the package to patch exists in the catalog
  # If package is found, update resource one-time for patching
  # If package is not found, create a one-time package resource
  def pre_run_check
    # Validate :patchday_class
    patchday_class = parameter(:patchday_class)
    begin
      retrieve_resource_reference(patchday_class.value)
    rescue ArgumentError => e
      raise Puppet::Error, "Parameter patchday_class failed: #{e} at #{@file}:#{@line}"
    end

    # Check for pending reboots
    puts :kernel
    puts Puppet[:kernel]
    kernel = Puppet[:kernel]
    pending_reboot = false
    case kernel.downcase
    when 'windows'
      sysroot = ENV['SystemRoot']
      powershell = "#{sysroot}\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
      # get the script path relative to the Puppet agent
      checker_script = File.join(
        __dir__,
        '..',
        'patching_as_code',
        'pending_reboot.ps1',
      )
      result = Puppet::Util::Execution.execute("#{powershell} -ExecutionPolicy Unrestricted -File #{checker_script}").to_s.downcase == 'true'
      pending_reboot = result
      puts "Check result: #{result}"
      case result
      when true
        puts 'Result is Boolean true'
      when false
        puts 'Result is Boolean false'
      else
        puts 'Result is non Boolean'
      end
    when 'linux'
      puts 'Not yet implemented'
    else
      raise Puppet::Error, "Patching_as_code - Unsupported Operating System type: #{kernel}"
    end
    puts "Pending_reboot: #{pending_reboot}"

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
