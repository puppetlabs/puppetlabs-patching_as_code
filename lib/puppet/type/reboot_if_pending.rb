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
    # Find all pre-reboot resources
    catalog.resources.each do |res|
      puts res
      puts res['tag']
    end

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
      # get the script path relative to the Puppet Type
      checker_script = File.join(
        __dir__,
        '..',
        '..',
        'patching_as_code',
        'pending_reboot.sh',
      )
      pending_reboot = Puppet::Util::Execution.execute("/bin/sh #{checker_script}").chomp.to_s.downcase == 'true'
    else
      raise Puppet::Error, "Patching as Code - Unsupported Operating System type: #{kernel}"
    end
    return unless pending_reboot

    Puppet.send('notice', 'Patching as Code - Pending OS reboot detected, node will reboot at start of patch window today')
    catalog.add_resource(Puppet::Type.type('reboot').new(
                           title: 'Patching as Code - Pending OS reboot',
                           apply: 'immediately',
                           schedule: parameter(:patch_window).value,
                           before: "Class[patching_as_code::#{kernel}::patchday]",
                         ))

    catalog.add_resource(Puppet::Type.type('notify').new(
                           title: 'Patching as Code - Performing Pending OS reboot before patching...',
                           schedule: parameter(:patch_window).value,
                           notify: 'Reboot[Patching as Code - Pending OS reboot]',
                           before: "Class[patching_as_code::#{kernel}::patchday]",
                         ))
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
