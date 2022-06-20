Puppet::Functions.create_function(:'patching_as_code::dedupe_arch') do
  dispatch :dedupe_arch do
    param 'Array', :patches
  end

  def dedupe_arch(patches)
    no_arch = patches.map { |patch| patch.sub(%r{(.noarch|.x86_64|.i386|.i686)$}, '') }
    multi_arch = no_arch.group_by { |x| x }.select { |_k, v| v.size > 1 }.map(&:first)
    result = patches.map do |patch|
      no_arch_patch = patch.sub(%r{(.noarch|.x86_64|.i386|.i686)$}, '')
      if multi_arch.include? no_arch_patch
        no_arch_patch
      else
        patch
      end
    end
    result.uniq
  end
end
