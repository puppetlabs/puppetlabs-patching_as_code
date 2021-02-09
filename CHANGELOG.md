# Changelog

All notable changes to this project will be documented in this file.

## Release 0.4.2

**Bugfixes**
- Account for `$facts['operatingsystemmajrelease']` returning a string instead of an integer

## Release 0.4.1

**Bugfixes**
- For parsing the result of `/usr/bin/needs-restarting -r` in CentOS 7/8, the script was `if [ $? -eq 0 ]` instead of `if [ $? -eq 1 ]`, which caused the logic to be flipped.

## Release 0.4.0

**Features**
- Completely rewrote the reboot behavior, so that pending reboot detections fully works both before patching and after patching, in the same Puppet run. There is no more dependency on the `reboots.reboot_required` portion of the `pe_patch`/`os_patching` fact, all logic is now internal and no longer requires multiple Puppet runs.
- Changed the default schedules to `reboot: ifneeded` (was `reboot: always`), now that the pending reboot logic has improved so much
- Ensured that pre_reboot commands will now trigger when necessary (only one scenario can happen at a time):
  - when an OS pending reboot is detected at the start of a run (before patching)
  - when an OS pending reboot is detected at the end of a run (after patching)
- Forced pre_reboot commands (which are essentially Exec resources) to use the `posix` provider on Linux and the `powershell` provider on Windows, so that the pending reboot detection logic can be injected to the resource dynamically.

## Release 0.3.0

**Features**
- Rewrote updating of Linux packages to use a custom type (`patch_package`), which dynamically updates and/or creates `package` resources for patching in the catalog on the agent side. This ensures no duplicate package declarations can occur on the server side, due to the parsing-order dependency of `defined()` and `defined_with_params()`. Neither of these functions are used anymore.

## Release 0.2.9

**Bugfixes**
- Also protect against duplicate package declarations when `ensure` is set to a version. This isn't 100% bulletproof as the check is parse-order-dependent, but will work in most cases.

## Release 0.2.8

**Bugfixes**
- Ensured Linux patches cannot cause duplicate declarations

## Release 0.2.7

**Bugfixes**
- Added dependency to `puppetlabs/puppet_agent` to the module's metadata

## Release 0.2.6

**Features**
- Added a `patch_unsafe_process_active` custom fact that reflects if any process from the `unsafe_process_list` parameter was found active on the system.
- Added a `unsafe_process_list` parameter to the `patching_as_code` class, which defines processes for the system that must cause patching to be skipped if any of those processes are active. Defaults to an empty array.

## Release 0.2.5

**Features**
- Added cache cleanup for other providers (dnf, apt, zypper)
- Added refresh of `pe_patch::fact::exec` / `os_patching::fact::exec` resources, to auto-update patch state after patching. This prevents unneccesary patching runs that perform no updates

**Bugfixes**
- Increased reboot delay after patching from 1 to 5 minutes, to account for remaining activities in the Puppet run

## Release 0.2.4

**Bugfixes**
- Fixes the datatype of the `metered_link` fact, this was expected to be Boolean but got reported as a String, causing the logic to break.

## Release 0.2.3

**Features**
- Added a `metered_link` custom fact that detects metered network connections on Windows
- Added a `patch_on_metered_links` parameter to the `patching_as_code` class, which controls if patches are installed when running over a metered link (Windows only). Defaults to `false`.

## Release 0.2.2

**Features**
- This update ensures that patching_as_code defaults to NOT classify the pe_patch class on PE 2019.8.0, so that you can use the builtin "PE Patch Management" node group(s) to classify pe_patch. Since UI will be further improved in PE for this, it makes sense that this would be the leading way to classify pe_patch. This module can still be given control over pe_patch, as described in the updated Readme.
- The blacklist and whitelist have been renamed to blocklist and allowlist.
- Documentation has been updated, with a reference for the main manifest.

## Release 0.2.1

**Bugfixes**
Ensure pre/post-patching & pre-reboot commands use the same schedule

## Release 0.2.0

Fixes pending reboot logic, adds pre/post-patching & pre-reboot command support

**Features**
- Ensures pending reboots are handled correctly, skipping patch installs completely
- Allows defining `Exec` resources dynamically for pre/post-patching & pre-reboot commands
- Refactors reboot logic into main manifest

**Known Issues**
Tested on Windows 2016 and 2019, and CentOS 7

## Release 0.1.0

Initial release

**Features**
- Integrates with `albatrossflavour/os_patching` and `puppetlabs/pe_patch`
- Customizable patch windows
- Patch window based on Nth weekday in the month
- Reboot control
- Yum clean support

**Known Issues**
Tested on Windows 2016 and 2019, and CentOS 7
