Puppet::Functions.create_function(:'patching_as_code::last_run') do
  dispatch :last_run do
    param 'Array', :patches
    param 'Array', :choco_patches
  end

  def last_run(patches, choco_patches)
    {
      'last_run' => Time.now.strftime('%Y-%m-%d %H:%M'),
      'patches_installed' => patches,
      'choco_patches_installed' => choco_patches,
    }.to_json
  end
end
