# Changelog

All notable changes to this project will be documented in this file.

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