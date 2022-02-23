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
  - [Defining situations when patching needs to be skipped](#defining-situations-when-patching-needs-to-be-skipped)
  - [Defining pre/post-patching and pre-reboot commands](#defining-prepost-patching-and-pre-reboot-commands)
  - [Limitations](#limitations)

## Description

This module provides automatic patch management for Linux, Windows and Chocolatey through desired state code.

## Setup

### What this module affects

This module will leverage the fact data provided by either the [albatrossflavour/os_patching](https://forge.puppet.com/albatrossflavour/os_patching) or PE 2019.8's builtin `pe_patch` module for OS patches and Linux application patches (when based on Linux package manager repositories). It is also able to detect outdated Chocolatey packages.
Once available patches are known via the above facts, the module will install the patches during the configured patch window.
* For Linux operating systems, this happens through the native Package resource in Puppet.
* For Windows operating systems, this happens through the `patching_as_code::kb` class, which comes with this module.
* For Chocolatey packages on Windows, this happens through the native Package resource in Puppet.
* By default, a reboot is only performed when necessary at the end of a patch run that actually installed patches. You can change this behavior though, to either always reboot or never reboot.
* You can define pre-patch, post-patch and pre-reboot commands for patching runs. We recommend that for Windows, you use Powershell-based commands for these. Specifically for pre-reboot commands on Windows, you *must* use Powershell-based commands.
* This module will report the details of the last successful patch run in a `patching_as_code` fact.
* This module will report the configuration for each node in a `patching_as_code_config` fact.
* This module will report outdated Chocolatey packages for each node in a `patching_as_code_choco` fact.

### Setup Requirements

To start with `patching_as_code`, complete the following prerequirements:
* Ensure this module and its dependencies are added to your control repo's Puppetfile.
* If you are **not** running Puppet Enterprise 2019.8.0 or higher, you'll also need to add the [albatrossflavour/os_patching](https://forge.puppet.com/albatrossflavour/os_patching) module to your control repo's Puppetfile.
* If you **are** running Puppet Enterprise 2019.8.0 or higher, the built-in `pe_patch` module will be used by default. You can however force the use of the `os_patching` module if so desired, by setting the optional `patching_as_code::use_pe_patch` parameter to `false`. To prevent duplicate declarations of the `pe_patch` class in PE 2019.8.0+, this module will default to NOT declaring the `pe_patch` class. This allows you to use the builtin "PE Patch Management" classification groups to classify `pe_patch`. If you however would like this module to control the classification of `pe_patch` for you (and sync the `patch_group` parameter, which is recommened), please set the `patching_as_code::classify_pe_patch` parameter to `true`.
* For Linux operating systems, ensure your package managers are pointing to repositories that are publishing new package versions as needed
* For Windows operating systems, ensure Windows Update is configured to check with a valid update server (either WSUS, Windows Update or Microsoft Update). If you want, you can use the [puppetlabs/wsus_client](https://forge.puppet.com/puppetlabs/wsus_client) module to manage the Windows Update configuration.
* For Chocolatey packages, ensure your Chocolatey is pointing to repositories that are publishing new package versions as needed


### Beginning with patching_as_code

To get started with the patching_as_code module, include it in your manifest:
```
include patching_as_code
```
or
```
class {'patching_as_code':}
```
This enables automatic detection of available OS patches, and puts all the nodes in the `primary` patch group.
By default this will patch your systems on the 3rd Friday of the month, between 22:00 and midnight (00:00), and perform a reboot if necessary.
On PE 2019.8 or newer this will not automatically classify the `pe_patch` class, so that you can control this through PE's builtin "PE Patch Management" node groups.

To allow patching_as_code to control & declare the `pe_patch` class, change the declaration to:
```
class {'patching_as_code':
  classify_pe_patch => true
}
```
This will change the behavior to also declare the `pe_patch` class, and match its `patch_group` parameter with this module's `patch_group` parameter. In this scenario, make sure you do not classify your nodes with `pe_patch` via the "PE Patch Management" node groups or other means.

To allow patching_as_code to control & declare the `pe_patch` class, and also patch Chocolatey packages, set the declaration to:
```
class {'patching_as_code':
  classify_pe_patch => true,
  patch_choco       => true
}
```

## Usage

To control which patch group(s) a node belongs to, you need to set the `patch_group` parameter of the class.
It is highly recommended to use Hiera to set the correct value for each node, for example:
```
patching_as_code::patch_group: early
```
The module provides 6 patch groups out of the box:
```
weekly:    patches each Thursday of the month, between 09:00 and 11:00, performs a reboot if needed
testing:   patches every 2nd Thursday of the month, between 07:00 and 09:00, performs a reboot if needed
early:     patches every 3rd Monday   of the month, between 20:00 and 22:00, performs a reboot if needed
primary:   patches every 3rd Friday   of the month, between 22:00 and 00:00, performs a reboot if needed
secondary: patches every 3rd Saturday of the month, between 22:00 and 00:00, performs a reboot if needed
late:      patches every 4th Saturday of the month, between 22:00 and 00:00, performs a reboot if needed
```
There are also 2 special built-in patch groups:
```
always:    patches immediately when a patch is available, can patch in any agent run, performs a reboot if needed
never:     never performs any patching and does not reboot
```

If you want to assign a node to multiple patch groups, specify an array of values in Hiera:
```
patching_as_code::patch_group:
  - testing
  - early
```
or, in flow style:
```
patching_as_code::patch_group: [ testing, early ]
```

Note: if you assign a node to multiple patch groups, the value for the patch group provided to `pe_patch`/`os_patching` will be a space-separated list of the assigned patch groups. This is because `pe_patch`/`os_patching` do not natively support multiple patch groups, so we work around this by converting our list a single string that `pe_patch`/`os_patching` can work with. This is purely for cosmetic purposes and does not affect the functionality of either solution.

When using a local apply for iterative development, the default `fact_upload => true` for `pe_patch` or `os_patching` may be problematic. If so, you can set `fact_upload => false` for `patching_os_code` to temporarily disable this behavior.

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
    reboot:        always | never | ifneeded
```
For example, say you want to have the following 2 patch groups:
```
group1: patches every 2nd Sunday of the month, between 10:00 and 11:00, max 1 time, reboots if needed
group2: patches every 3nd and 4th Monday of the month, between 20:00 and 22:00, max 3 times, does not reboot
group3: patches every day in the 3rd week of the month, between 18:00 and 20:00, max 4 times, always reboots

```
then define the hash as follows:
```
patching_as_code::patch_schedule:
  group1:
    day_of_week: Sunday
    count_of_week: 2
    hours: 10:00 - 11:00
    max_runs: 1
    reboot: ifneeded
  group2:
    day_of_week: Monday
    count_of_week: [3,4]
    hours: 20:00 - 22:00
    max_runs: 3
    reboot: never
  group3:
    day_of_week: Any
    count_of_week: 3
    hours: 18:00 - 20:00
    max_runs: 4
    reboot: always
```

## Controlling which patches get installed

If you need to limit which patches can get installed, use the blocklist/allowlist capabilties. This is best done through Hiera by defining an array values for `patching_as_code::blocklist` and/or `patching_as_code::allowlist` for Windows Updates and Linux packages. For Chocolatey packages, separate Hiera values `patching_as_code::blocklist_choco` and/or `patching_as_code::allowlist_choco` can be set.

To prevent KB2881685 and the 7zip Chocolatey package from getting installed/updated on Windows:
```
patching_as_code::blocklist:
  - KB2881685
patching_as_code::blocklist_choco:
  - 7zip
```
To only allow the patching of a specific set of 3 Linux packages:
```
patching_as_code::allowlist:
  - grafana
  - redis
  - nano
```
Allow lists and block lists can be combined, in that case the list of available updates first gets reduced to the what is allowed by the allowlist, and then gets further reduced by any blocklisted updates.

## Defining situations when patching needs to be skipped

There could be situations where you don't want patching to occur if certain conditions are met. This module supports two such situations:

* A specific process is running that must not be interrupted by patching
* The node to be patched is currently connected via a metered link (Windows only)

### Managing unsafe processes for patching

You can define a list of unsafe processes which, if any are found to be active on the node, should cause patching to be skipped. This is best done through Hiera, by defining an array value for `patching_as_code::unsafe_process_list`.

To skip patching if `application1` or `application2` is among the active processes:
```
patching_as_code::unsafe_process_list:
  - application1
  - application2
```

This works on both Linux and Windows, and the matching is done case-insensitive. If one process from the `unsafe_process_list` is found as an active process, patching will be skipped.

### Managing patching over metered links (Windows only)

By default, this module will not perform patching over metered links (e.g. 3G/4G connections). You can control this behavior through the `patch_on_metered_links` parameter. To force patching to occur even over metered links, either define this value in Hiera:
```
patching_as_code::patch_on_metered_links: true
```
or set this parameter as part of calling the class:
```
class {'patching_as_code':
  patch_on_metered_links => true
}
```

## Defining pre/post-patching and pre-reboot commands

You can control additional commands that get executed at specific times, to facilitate the patch run. For example, you may want to shutdown specific applications before patching, or drain a kubernetes node before rebooting. The order of operations is as follows:
1) If reboots are enabled, check for pending reboots and reboot system immediately if a pending reboot is found
2) Run pre-patching commands
3) Install patches
4) Run post-patching commands
5) If reboots are enabled, run pre-reboot commands (if a reboot is pending, or when reboots are set to `always`)
6) If reboots are enabled, reboot system (if a reboot is pending, or when reboots are set to `always`)

To define the pre/post-patching and pre-reboot commands, you need to create hashes in Hiera. The commands will be executed as `Exec` resources, and you can use any of the [allowed attributes](https://puppet.com/docs/puppet/6.17/types/exec.html#exec-attributes) for that resource (just don't use metaparameters). There are 3 hashes you can define:
```
patching_as_code::pre_patch_commands
patching_as_code::post_patch_commands
patching_as_code::pre_reboot_commands
```

It's best to define this in Hiera, so that the commands can be tailored to individual nodes or groups of nodes.
A hash for a command (let's use pre-reboot as an example) looks like this in Hiera:
```
patching_as_code::pre_reboot_commands:
  prep k8s for reboot:
    command: /usr/bin/kubectl drain k8s-3.company.local --ignore-daemonsets --delete-local-data
```
Here's another example, this time for a pre-patch powershell command on Windows:
```
patching_as_code::pre_patch_commands:
  shutdown SQL server:
    command: Stop-Service MSSQLSERVER -Force 
    provider: powershell
```
As you can see, it's just like defining `Exec` resources.

Note that specifically for `patching_as_code::pre_reboot_commands`, the `provider:`, `onlyif:` and `unless:` parameters will be ignored, as these are overwritten by the internal logic to detect pending reboots. On Linux the `provider:` is forced to `posix`, on Windows it is forced to `powershell`.

## Limitations

This solution will patching to initiate whenever an agent run occurs inside the patch window. On Windows, patch runs for Cumulative Updates can take a long time, so you may want to tune the hours of your patch windows to account for a patch run getting started near the end of the window and still taking a significant amount of time.
