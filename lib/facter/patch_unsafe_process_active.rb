require 'pathname'

Facter.add('patch_unsafe_process_active') do
  confine { Facter.value(:kernel) == 'windows' || Facter.value(:kernel) == 'Linux' }
  setcode do
    def process_running(processname, full = false)
      kernel = 'Linux'
      case kernel
      when 'windows'
        if full
          tasklist = `wmic path win32_process get Commandline`.downcase
          processname = processname[6..-1].strip
        else
          tasklist = `wmic path win32_process get Caption`.downcase
        end
      when 'Linux'
        if full
          tasklist = `ps -Ao cmd`.downcase
          processname = processname[6..-1].strip
        else
          tasklist = `ps -Ao comm`.downcase
        end
      end
      tasklist.include? processname.downcase
    end

    processfile = Pathname.new(Puppet.settings['confdir'] + '/patching_unsafe_processes')
    result = false
    if processfile.exist?
      unsafe_processes = File.open(processfile, 'r').read
      unsafe_processes.each_line do |line|
        next if line.match?(%r{^#|^$})
        if line.match?(%r{^{full}})
          next if process_running(line.chomp, true) == false
        elsif process_running(line.chomp) == false
          next
        end
        result = true
        break
      end
    end
    puts result
  end
end
