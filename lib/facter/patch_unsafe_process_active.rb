require 'pathname'

Facter.add('patch_unsafe_process_active') do
  confine { Facter.value(:kernel) == 'windows' || Facter.value(:kernel) == 'Linux' }
  setcode do
    def process_running(processname)
      case Facter.value(:kernel)
      when 'windows'
        tasklist = `tasklist`.downcase
      when 'Linux'
        tasklist = `ps -A`.downcase
      end
      tasklist.include? processname.downcase
    end

    processfile = Pathname.new(Puppet.settings['confdir'] + '/patching_unsafe_processes')
    result = false
    if processfile.exist?
      unsafe_processes = File.open(processfile, 'r').read
      unsafe_processes.each_line do |line|
        next if line.match?(%r{^#|^$})
        next if process_running(line.chomp) == false
        result = true
        break
      end
    end
    result
  end
end
