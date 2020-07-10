# puppetlabs-patching_as_code

#### Table of Contents

- [puppetlabs-patching_as_code](#puppetlabs-patching_as_code)
      - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Setup](#setup)
    - [What this module affects](#what-this-module-affects)
    - [Setup Requirements](#setup-requirements)
    - [Beginning with patching_as_code](#beginning-with-patching_as_code)
  - [Usage](#usage)
    - [Customizing the patch groups](#customizing-the-patch-groups)
  - [Controlling which patches get installed](#controlling-which-patches-get-installed)
  - [Limitations](#limitations)

## Description

This module provides automatic patch management for Linux and Windows through desired state code.

## Setup

### What this module affects

This module will leverage the fact data provided by either the [albatrossflavour/os_patching](https://forge.puppet.com/albatrossflavour/os_patching) or PE 2019.8's builtin `pe_patch` module.
Once available patches are known via the above facts, the module will install the patches during the configured patch window.
* For Linux operating systems, this happens through the native Package resource.
* For Windows operating systems, this happens through the `windows_updates::kb` class, which requires the [noma4i/windows_updates](https://forge.puppet.com/noma4i/windows_updates) module to be installed.
* A reboot is always performed at the end of a patch run that actually installed patches.

### Setup Requirements

To start with patching_as_code, complete the following prerequirements:
* Ensure this module and its dependencies are added to your control repo's Puppetfile
* If you are **not** running on Puppet Enterprise 2019.8.0 or higher, you'll also need to add the [albatrossflavour/os_patching](https://forge.puppet.com/albatrossflavour/os_patching) module to your control repo's Puppetfile
* For Linux operating systems, ensure your package managers are pointing to repositories that are publishing new package versions as needed
* For Windows operating systems, ensure Windows Update is configured to check with a valid update server (either WSUS, Windows Update or Microsoft Update). If you want, you can use the [puppetlabs/wsus_client](https://forge.puppet.com/puppetlabs/wsus_client) module to manage the Windows Update configuration.

### Beginning with patching_as_code

To get started with the patching_as_code module, include it in your manifest:
```
include patching_as_code
```

This enables automatic detection of available patches, and put all the nodes in the `primary` patch group.
By default this will patch your systems on the 3rd Friday of the month, between 22:00 and midnight (00:00).

## Usage

To control which patch group a node belongs to, you need to set `patch_group` parameter of the class.
It is highly recommended to use Hiera to set the correct value for each node:
```
patching_as_code::patch_group: early
```

The module provides 5 patch groups out of the box:
```
testing:   patches every 2nd Thursday of the month, between 07:00 and 09:00
early:     patches every 3rd Monday   of the month, between 20:00 and 22:00
primary:   patches every 3rd Friday   of the month, between 22:00 and 00:00
secondary: patches every 3rd Saturday of the month, between 22:00 and 00:00
late:      patches every 4th Saturday of the month, between 22:00 and 00:00
```

There are also 2 special built-in patch groups:
```
always:    patches immediately when a patch is available, can patch in any agent run
never:     never performs any patching
```

### Customizing the patch groups

You can customize the patch groups to whatever you need. To do so, simply copy the `patching_as_code::patch_schedule` hash from the `data/common.yaml` in this module, and paste it into your own Hiera store (recommended to place it in your Hiera's own `common.yaml`). This Hiera value will now override the defaults that the module provides. Customize the hash to your needs.

The hash has the following structure:
```
patching_as_code::patch_schedule:
  <name of patch group>:
    day_of_week:   <day to patch systems>
    count_of_week: <the Nth time day_of_week occurs in the month>
    hours:         <start of patch window> - <end of patch window>
    max_runs:      <max number of times that Puppet can perform patching within the patch window>
```

For example, say you want to have the following 2 patch groups:
```
group1: patches every 2nd Sunday of the month, between 10:00 and 11:00, max 1 time
group2: patches every 3nd Monday of the month, between 20:00 and 22:00, max 3 times
```
then define the hash as follows:
```
patching_as_code::patch_schedule:
  group1:
    day_of_week: Sunday
    count_of_week: 2
    hours: 10:00 - 11:00
    max_runs: 1
  group2:
    day_of_week: Monday
    count_of_week: 3
    hours: 20:00 - 22:00
    max_runs: 3
```

## Controlling which patches get installed

If you need to limit which patches can get installed, use the blacklist/whitelist capabilties. This is best done through Hiera.

To prevent KB2881685 from getting installed:
```
patching_as_code::blacklist:
  - KB2881685
```

To only allow the installation of a specific set of 3 KB articles:
```
patching_as_code::whitelist:
  - KB123456
  - KB234567
  - KB345678
```

Both options can be combined, in that case the list of available updates first gets reduced to the what is allowed by the whitelist, and then gets further reduced by any blacklisted updates.

## Limitations

This solution will patching to initiate whenever an agent run occurs inside the patch window. On Windows, patch runs for Cumulative Updates can take a long time, so you may want to tune the hours of your patch windows to account for a patch run getting started near the end of the window and still taking a significant amount of time.