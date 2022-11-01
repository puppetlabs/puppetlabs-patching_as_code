# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.1.6](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.6) (2022-11-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.6...v1.1.6)

### UNCATEGORIZED PRS; LABEL THEM ON GITHUB

- Release 1.1.7: More robust reboot check and update docs [\#79](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/79) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.6](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.6) (2022-09-28)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.5...v1.1.6)

### Fixed

- fix release versions to match tags [\#74](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/74) ([binford2k](https://github.com/binford2k))
- improved logic for pre\_reboot\_commands [\#73](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/73) ([kreeuwijk](https://github.com/kreeuwijk))
- setting up history for auto changelog generation [\#72](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/72) ([binford2k](https://github.com/binford2k))

# Changelog

All notable changes to this project will be documented in this file.

## v1.1.5

**Improvements**
- Added support for RHEL 9 in the reboot detection script.

## v1.1.4

**Improvements**
- Added support for matching against full process arguments for the `patching_as_code::unsafe_process_list`.

## v1.1.3

**Bugfixes**
- No longer logs `Puppet Unknown variable: 'reboot'` on runs outside of the patch day.

**Improvements**
- Correctly handles multi-architecture package updates, e.g. when there is an update for both the `i686` and `x86_64` version of a package.

## v1.1.2

**Bugfixes**
- Fixes a bug that caused High Priority OS patches for Windows not to be installed, due to the wrong variable being used.

**Improvements**
- Deduplicates the list of installed patches on the last run, reported in the `patching_as_code` fact.

## v1.1.1

**Improvements**
- Fix incorrect YAML code markers in `README.md`.

## v1.1.0

**Features**
- Adds support for high priority patches on an alternate patch schedule.
- Adds `high_priority_only` parameter to the `patching_as_code` class, for compatibility with the `puppetlabs/change_window` module.

**Improvements**
- Ensures the last_run fact data only gets written during the patch window.

## v1.0.5

**Bugfixes**
- Moves the location of the `patching_as_code` fact content to `/opt/puppetlabs/patching_as_code` (or `%ProgramData%\PuppetLabs\patching_as_code` on Windows), to remove a dependency on `pe_patch/os_patching` creating the directory where the last_run file content can be stored.
- Fixes an incompatibility with `os_patching` that was caused by the wrong directory being assumed for the `patching_as_code` fact content when using `os_patching`.

## v1.0.4

**Features**
- Added a `patching_as_code` fact that details the date & time of the last successful patch run, as well as which packages were installed.

## v1.0.3

**Bugfixes**
- No longer adds `Exec[Patching as Code - Clean Cache]` to the `require` metaparameter of managed Chocolatey package resources that will be patched.

## v1.0.2

**Improvements**
- Split the `allowlist` and `blacklist` to have dedicated lists for Chocolatey, with the new `allowlist_choco` and `blacklist_choco` parameters. These new parameters now must be used for Chocolatey packages, the regular `allowlist` and `blacklist` will not affect Chocolatey packages anymore.
- Pending OS reboots will now no longer occur if `enable_patching` has been changed to `false`. This is to enable the `enable_patching` parameter being used as a single switch to ensure that no disruptive action can happen at all.

## v1.0.1

**Bugfixes**
- Improved processing of the `patching_as_config_choco` fact, to ensure backwards compatibility with Facter 3.
- The `patching_as_config_choco` fact now no longer errors on a system that does not have `patching_as_config` enabled.

## v1.0.0

**Features**
- Added ability to update Chocolatey packages as part of the patching run, by setting `patch_choco => true`. Allowlist & blocklist settings will be applied to Chocolatey packages as well.

**Improvements**
- Enable control of behavior for automatic uploading of facts by the `pe_patch` and `os_patching` modules (contributed by @prolixalias)
- Fix cause of deprecation message `Calling function empty() with Numeric value is deprecated` (contributed by @prolixalias)

## v0.7.11

**Improvements**
- Deduplicates the list of patches to install, preventing any possible duplicate resource declarations if the list of patches to install contains the same patch more than once for any reason

## v0.7.10

**Improvements**
- Allow reinstalls of KB4052623 as these are also monthly AV definition updates

## v0.7.9

**Bugfixes**
- Correct KB2267202 to KB2267602

## v0.7.8

**Improvements**
- Allow reinstalls of KB2267202 and KB2461484 as these are monthly AV definition updates

## v0.7.7

**Bugfixes**
- Removed a dependency on the `patching_as_code_config` fact inside of the `is_patchday()` function, preventing possible catalog compilation failures as a result of the `patching_as_code_config` fact not yet existing for new agents.

## v0.7.6

**Bugfixes**
- Account for the `patching_as_code_utc_offset` fact to be empty in some situations

## v0.7.5

**Improvements**
- Now correctly adjusts for timezone differences between the Puppet Server and the managed node, ensuring that the local node time & date gets used to calculate if today is patch day.
- Now logs messages in the Puppet Server log to report the calculated local node time & day, as well as whether or not today is patch day for the node.

## v0.7.4

**Bugfixes**
- Fixes a missing `schedule` metaparameter for the `Notify[Patching as Code - Update Fact]`, which would cause the `pe_patch` fact to update at every Puppet run during the patch day, instead of only during the maintenance window.

## v0.7.3

**Bugfixes**
- Correctly handles package declarations where the title of the package resource does not match the name of the package.

## v0.7.2

**Improvements**
- The pre-patch reboot in case of any pending reboots now happens also if it is patchday but there are no patches to install. This facilitates parallel patching tools to have installed patches before Puppet's patch window, with Puppet performing the actual reboot.

## v0.7.1

**Improvements**
- Adopted the `eval_generate` function in the `patch_package` type to ensure that newly generated `package` resources become children of the `patching_as_code::linux::patchday` class. This provides better context for these package resources, which can be leveraged in external reporting tools (e.g. Splunk).
- Simplified the `patch_package` type, removed capabilities that are no longer needed
- Moved the logic to trigger the patch fact refresh to the main manifest
- Simplified the patchday classes

## v0.7.0

**Features**
- Moves the post-patch reboot logic to its own stage (`patch_reboot`), which runs after the `main` stage. This should ensure that reboots only happen at the end of the Puppet run.
- Removed the `notify` logic for triggering the reboots from installed patches, in favor of handling the reboot logic in the new `patch_reboot` stage.
- Deduplicated the calling of the Exec resource that refreshes the patch fact, ensuring this only happens once now.

## v0.6.2

**Features**
- Adds support for setting the value `Any` to the `day_of_week` parameter in a patch schedule

## v0.6.1

**Bugfixes**
- Removed the `weekday` attribute of the `schedule` resource that this module uses internally to restrict when patches can be applied. In certain edge cases where the Puppet server is in a very different timezone from a managed node, there can be a 1 day date difference between the two systems. This creates a scenario where the node never receives a valid patch schedule. By removing the `weekday` parameter from the `schedule` resource, this can no longer occur. Other logic still protects the actual day on which the patching is allowed so this parameter wasn't necessary.

## v0.6.0

**Features**
- Adds support for providing an array of values to the `patch_group` attribute of the `patching_as_code` class
- Adds support for providing an array of values to the `count_of_week` parameter in a patch schedule

## v0.5.0

**Features**
- Removes dependency on the `windows_updates` module, we can now install Windows Updates natively
- Adds a Task to install a Windows Update over WinRM or PCP
- Updates the PDK to 2.0.0
- No longer fails the resource if the Windows Update is no longer available/applicable for the node
- Write a `patching_as_code_config` fact that reports configuration state
- Support security-only patching via a new `security_only` parameter to the class. This works for Linux today, but requires a not-yet shipped update to `pe_patch` for Windows
- Preparations for being able to run `patching_as_code` as a plan, not yet active.

## v0.4.3

**Bugfixes**
- Ensure `yum-utils` package on all RedHat/CentOS versions, not just 8
- Use `ensure_packages()` for safer enforcement of `yum-utils` package

## v0.4.2

**Bugfixes**
- Account for `$facts['operatingsystemmajrelease']` returning a string instead of an integer

## v0.4.1

**Bugfixes**
- For parsing the result of `/usr/bin/needs-restarting -r` in CentOS 7/8, the script was `if [ $? -eq 0 ]` instead of `if [ $? -eq 1 ]`, which caused the logic to be flipped.

## v0.4.0

**Features**
- Completely rewrote the reboot behavior, so that pending reboot detections fully works both before patching and after patching, in the same Puppet run. There is no more dependency on the `reboots.reboot_required` portion of the `pe_patch`/`os_patching` fact, all logic is now internal and no longer requires multiple Puppet runs.
- Changed the default schedules to `reboot: ifneeded` (was `reboot: always`), now that the pending reboot logic has improved so much
- Ensured that pre_reboot commands will now trigger when necessary (only one scenario can happen at a time):
  - when an OS pending reboot is detected at the start of a run (before patching)
  - when an OS pending reboot is detected at the end of a run (after patching)
- Forced pre_reboot commands (which are essentially Exec resources) to use the `posix` provider on Linux and the `powershell` provider on Windows, so that the pending reboot detection logic can be injected to the resource dynamically.

## v0.3.0

**Features**
- Rewrote updating of Linux packages to use a custom type (`patch_package`), which dynamically updates and/or creates `package` resources for patching in the catalog on the agent side. This ensures no duplicate package declarations can occur on the server side, due to the parsing-order dependency of `defined()` and `defined_with_params()`. Neither of these functions are used anymore.

## v0.2.9

**Bugfixes**
- Also protect against duplicate package declarations when `ensure` is set to a version. This isn't 100% bulletproof as the check is parse-order-dependent, but will work in most cases.

## v0.2.8

**Bugfixes**
- Ensured Linux patches cannot cause duplicate declarations

## v0.2.7

**Bugfixes**
- Added dependency to `puppetlabs/puppet_agent` to the module's metadata

## v0.2.6

**Features**
- Added a `patch_unsafe_process_active` custom fact that reflects if any process from the `unsafe_process_list` parameter was found active on the system.
- Added a `unsafe_process_list` parameter to the `patching_as_code` class, which defines processes for the system that must cause patching to be skipped if any of those processes are active. Defaults to an empty array.

## v0.2.5

**Features**
- Added cache cleanup for other providers (dnf, apt, zypper)
- Added refresh of `pe_patch::fact::exec` / `os_patching::fact::exec` resources, to auto-update patch state after patching. This prevents unneccesary patching runs that perform no updates

**Bugfixes**
- Increased reboot delay after patching from 1 to 5 minutes, to account for remaining activities in the Puppet run

## v0.2.4

**Bugfixes**
- Fixes the datatype of the `metered_link` fact, this was expected to be Boolean but got reported as a String, causing the logic to break.

## v0.2.3

**Features**
- Added a `metered_link` custom fact that detects metered network connections on Windows
- Added a `patch_on_metered_links` parameter to the `patching_as_code` class, which controls if patches are installed when running over a metered link (Windows only). Defaults to `false`.

## v0.2.2

**Features**
- This update ensures that patching_as_code defaults to NOT classify the pe_patch class on PE 2019.8.0, so that you can use the builtin "PE Patch Management" node group(s) to classify pe_patch. Since UI will be further improved in PE for this, it makes sense that this would be the leading way to classify pe_patch. This module can still be given control over pe_patch, as described in the updated Readme.
- The blacklist and whitelist have been renamed to blocklist and allowlist.
- Documentation has been updated, with a reference for the main manifest.

## v0.2.1

**Bugfixes**
Ensure pre/post-patching & pre-reboot commands use the same schedule

## v0.2.0

Fixes pending reboot logic, adds pre/post-patching & pre-reboot command support

**Features**
- Ensures pending reboots are handled correctly, skipping patch installs completely
- Allows defining `Exec` resources dynamically for pre/post-patching & pre-reboot commands
- Refactors reboot logic into main manifest

**Known Issues**
Tested on Windows 2016 and 2019, and CentOS 7

## v0.1.0

Initial release

**Features**
- Integrates with `albatrossflavour/os_patching` and `puppetlabs/pe_patch`
- Customizable patch windows
- Patch window based on Nth weekday in the month
- Reboot control
- Yum clean support

**Known Issues**
Tested on Windows 2016 and 2019, and CentOS 7


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
