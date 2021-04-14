plan patching_as_code::patch_run(
  Optional[TargetSpec] $targets,
#  Optional[String] $patch_group,
#  Optional[String] $pql,
#  Optional[Boolean] $force = false
){

  run_plan(puppetdb_fact, $targets)

  $result = apply($targets){
    class{'patching_as_code':
      allowlist              => $facts['patching_as_code_config']['allowlist'],
      blocklist              => $facts['patching_as_code_config']['blocklist'],
      enable_patching        => true,
      patch_group            => $facts['patching_as_code_config']['patch_group'],
      patch_on_metered_links => $facts['patching_as_code_config']['patch_on_metered_links'],
      patch_schedule         => {
        $facts['patching_as_code_config']['patch_group'] =>
        $facts['patching_as_code_config']['patch_schedule']
      },
      plan_patch_fact        => $facts['patching_as_code_config']['patch_fact'],
      post_patch_commands    => $facts['patching_as_code_config']['post_patch_commands'],
      pre_patch_commands     => $facts['patching_as_code_config']['pre_patch_commands'],
      pre_reboot_commands    => $facts['patching_as_code_config']['pre_reboot_commands'],
      security_only          => $facts['patching_as_code_config']['security_only'],
      unsafe_process_list    => $facts['patching_as_code_config']['unsafe_process_list'],
    }
  }

  out::message("${result}")
}
