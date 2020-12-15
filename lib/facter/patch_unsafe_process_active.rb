require 'pathname'

Facter.add('patch_unsafe_process_active') do
  confine kernel: 'windows'
  setcode do
    def process_running(processname)
      tasklist = `tasklist`.downcase
      true if tasklist.include? processname.downcase
    end
    
    processfile = Pathname.new(Puppet.settings['confdir'] + '/patching_unsafe_processes')
    result = false
    if processfile.exist?
      tasklist = `tasklist`.downcase
      unsafe_processes = File.open(processfile, 'r').read
      unsafe_processes.each_line do |line|
        next if line =~ /^#|^$/
        next if process_running(line.chomp) == false
        result = true
        break
      end
    end
    result
  end
end
