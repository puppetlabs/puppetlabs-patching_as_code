<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v2.0.0) - 2024-08-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.9...v2.0.0)

### Other

- fix dates [#104](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/104) ([spotter-puppet](https://github.com/spotter-puppet))
- V2.0.0 [#103](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/103) ([spotter-puppet](https://github.com/spotter-puppet))
- V1.1.8 [#100](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/100) ([spotter-puppet](https://github.com/spotter-puppet))

## [v1.1.9](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.9) - 2024-08-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.7...v1.1.9)

### Fixed

- Fix unsafe process list [#89](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/89) ([kreeuwijk](https://github.com/kreeuwijk))

### Other

- V1.1.8 [#100](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/100) ([spotter-puppet](https://github.com/spotter-puppet))
-  Powershell scripts should be executed with the -NoProfile parameter [#96](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/96) ([elfranne](https://github.com/elfranne))
- Exclude 'patching_as_code' fact from running on Darwin systems [#93](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/93) ([kennyb-222](https://github.com/kennyb-222))
- Pdk release prep fix fix [#92](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/92) ([kreeuwijk](https://github.com/kreeuwijk))
- fix PDK Release Prep action step [#91](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/91) ([kreeuwijk](https://github.com/kreeuwijk))
- remove travis [#87](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/87) ([binford2k](https://github.com/binford2k))

## [v1.1.7](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.7) - 2022-11-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.6...v1.1.7)

### Fixed

- Release 1.1.7: More robust reboot check and update docs [#79](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/79) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.6](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.6) - 2022-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.5...v1.1.6)

### Fixed

- fix release versions to match tags [#74](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/74) ([binford2k](https://github.com/binford2k))
- improved logic for pre_reboot_commands [#73](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/73) ([kreeuwijk](https://github.com/kreeuwijk))
- setting up history for auto changelog generation [#72](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/72) ([binford2k](https://github.com/binford2k))

## [v1.1.5](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.5) - 2022-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.4...v1.1.5)

### Other

- Release 1.1.5: RHEL 9 reboot detection support [#65](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/65) ([kreeuwijk](https://github.com/kreeuwijk))
- Add RHEL9 support to pending_reboot.sh [#64](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/64) ([jcpunk](https://github.com/jcpunk))
- Full process detection for `unsafe_process_list` [#62](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/62) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.4](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.4) - 2022-07-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.3...v1.1.4)

### Other

- v1.1.3: support linux updates for multiple architectures [#59](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/59) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.3](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.3) - 2022-06-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.2...v1.1.3)

### Other

- Correct the source parameter [#58](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/58) ([binford2k](https://github.com/binford2k))
- Added the Trusted Contributor notice [#56](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/56) ([binford2k](https://github.com/binford2k))
- v1.1.2: Fix High Priority patches not getting installed on Windows [#51](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/51) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.2) - 2022-03-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.1...v1.1.2)

## [v1.1.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.1) - 2022-03-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.1.0...v1.1.1)

### Other

- v1.1.0: High priority patching support [#50](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/50) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.1.0) - 2022-03-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.5...v1.1.0)

### Other

- v1.1.0: High priority patching support [#50](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/50) ([kreeuwijk](https://github.com/kreeuwijk))
- v1.0.5: Use own location for `patching_as_code` fact [#49](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/49) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.5](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.5) - 2022-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.4...v1.0.5)

### Other

- v1.0.5: Use own location for `patching_as_code` fact [#49](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/49) ([kreeuwijk](https://github.com/kreeuwijk))
- v1.0.4: `patching_as_code` fact [#47](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/47) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.4](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.4) - 2022-02-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.3...v1.0.4)

### Other

- v1.0.4: `patching_as_code` fact [#47](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/47) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.3](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.3) - 2022-02-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.2...v1.0.3)

### Other

- v1.0.2: Unique allow/block lists for Chocolatey [#45](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/45) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.2) - 2022-02-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.1...v1.0.2)

### Other

- v1.0.2: Unique allow/block lists for Chocolatey [#45](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/45) ([kreeuwijk](https://github.com/kreeuwijk))
- v1.0.1: Improve handling of `patching_as_code_choco` fact [#44](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/44) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.1) - 2022-02-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v1.0.0...v1.0.1)

### Other

- v1.0.1: Improve handling of `patching_as_code_choco` fact [#44](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/44) ([kreeuwijk](https://github.com/kreeuwijk))
- v1.0.0: Add Chocolatey support [#43](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/43) ([kreeuwijk](https://github.com/kreeuwijk))

## [v1.0.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v1.0.0) - 2022-02-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.11...v1.0.0)

### Other

- v1.0.0: Add Chocolatey support [#43](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/43) ([kreeuwijk](https://github.com/kreeuwijk))
- work around deprecation message [#42](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/42) ([prolixalias](https://github.com/prolixalias))
- backward-compatible disabling of os_patching's fact_upload [#41](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/41) ([prolixalias](https://github.com/prolixalias))
- v0.7.11: Fix issues caused by duplicate items in list of patches [#40](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/40) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.11](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.11) - 2021-12-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.10...v0.7.11)

### Other

- v0.7.11: Fix issues caused by duplicate items in list of patches [#40](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/40) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.10](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.10) - 2021-11-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.9...v0.7.10)

### Other

- Update to allow for Windows 10 Monthly updates [#38](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/38) ([robkae](https://github.com/robkae))

## [v0.7.9](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.9) - 2021-11-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.8...v0.7.9)

### Other

- puppet call ref : 46438 should be KB2267602 [#37](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/37) ([robkae](https://github.com/robkae))

## [v0.7.8](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.8) - 2021-11-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.7...v0.7.8)

## [v0.7.7](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.7) - 2021-09-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.6...v0.7.7)

## [v0.7.6](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.6) - 2021-08-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.5...v0.7.6)

### Other

- v0.7.5: better timezone support [#35](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/35) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.5](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.5) - 2021-08-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.4...v0.7.5)

### Other

- v0.7.4: schedule fix in Notify resource [#34](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/34) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.4](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.4) - 2021-08-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.3...v0.7.4)

### Other

- v0.7.4: schedule fix in Notify resource [#34](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/34) ([kreeuwijk](https://github.com/kreeuwijk))
- v0.7.3: Custom resource title support [#33](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/33) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.3](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.3) - 2021-08-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.2...v0.7.3)

### Other

- v0.7.3: Custom resource title support [#33](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/33) ([kreeuwijk](https://github.com/kreeuwijk))
- v0.7.2 - Allow reboots when pending on patch day [#31](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/31) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.2) - 2021-07-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.1...v0.7.2)

### Other

- v0.7.2 - Allow reboots when pending on patch day [#31](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/31) ([kreeuwijk](https://github.com/kreeuwijk))
- v0.7.1 - code improvements (#28) [#30](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/30) ([kreeuwijk](https://github.com/kreeuwijk))
- v0.7.1 - code improvements [#28](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/28) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.1) - 2021-06-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.7.0...v0.7.1)

### Other

- v0.7.1 - code improvements [#28](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/28) ([kreeuwijk](https://github.com/kreeuwijk))
- Move post-patch reboot logic to its own stage that runs after [main] [#27](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/27) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.7.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.7.0) - 2021-06-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.6.2...v0.7.0)

### Other

- Move post-patch reboot logic to its own stage that runs after [main] [#27](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/27) ([kreeuwijk](https://github.com/kreeuwijk))
- Update boundaries for powershell [#24](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/24) ([PolaricEntropy](https://github.com/PolaricEntropy))
- v0.6.2 - Support daily schedule [#23](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/23) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.6.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.6.2) - 2021-04-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.6.1...v0.6.2)

### Other

- v0.6.1 - Fix wide timezone difference case [#22](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/22) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.6.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.6.1) - 2021-04-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.6.0...v0.6.1)

### Other

- v0.6.0 - patch_group and scheduling improvements [#21](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/21) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.6.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.6.0) - 2021-04-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.5.0...v0.6.0)

### Other

- Update branch with 0.5.0 changes [#20](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/20) ([kreeuwijk](https://github.com/kreeuwijk))
- Version 0.5.0 - Native Windows Update support [#19](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/19) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.5.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.5.0) - 2021-04-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.4.3...v0.5.0)

### Other

- win_update feature [#18](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/18) ([](https://github.com/))

## [v0.4.3](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.4.3) - 2021-02-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.4.2...v0.4.3)

## [v0.4.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.4.2) - 2021-02-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.4.1...v0.4.2)

## [v0.4.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.4.1) - 2021-02-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.4.0...v0.4.1)

### Other

- v0.4.0 - Rewrote reboot behavior [#14](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/14) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.4.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.4.0) - 2021-02-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.3.0...v0.4.0)

## [v0.3.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.3.0) - 2021-01-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.9...v0.3.0)

### Other

- Version 0.3.0 - Custom type to prevent duplicate package declarations [#13](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/13) ([kreeuwijk](https://github.com/kreeuwijk))
- Support existing package declarations that specify a version [#12](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/12) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.9](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.9) - 2021-01-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.8...v0.2.9)

### Other

- Support existing package declarations that specify a version [#12](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/12) ([kreeuwijk](https://github.com/kreeuwijk))
- Fix risk of duplicate declarations [#11](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/11) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.8](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.8) - 2021-01-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.7...v0.2.8)

## [v0.2.7](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.7) - 2020-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.6...v0.2.7)

### Other

- v0.2.6 - skip patching if an unsafe process is active [#9](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/9) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.6](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.6) - 2020-12-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.5...v0.2.6)

### Other

- Clean pkg mgr cache for more providers, notify patch fact update [#8](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/8) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.5](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.5) - 2020-12-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.4...v0.2.5)

### Other

- Version 0.2.4: fix datatype of metered_link fact [#6](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/6) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.4](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.4) - 2020-11-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.3...v0.2.4)

### Other

- Add control for metered links [#5](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/5) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.3](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.3) - 2020-10-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.2...v0.2.3)

### Other

- Update to Release 0.2.2 [#4](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/4) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.2](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.2) - 2020-08-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.1...v0.2.2)

### Other

- Release preparation for 0.2.2 [#3](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/3) ([kreeuwijk](https://github.com/kreeuwijk))
- Ensure no duplicate declarations happen with pe_patch [#2](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/2) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.1](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.1) - 2020-07-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.2.0...v0.2.1)

### Other

- Pre post reboot control [#1](https://github.com/puppetlabs/puppetlabs-patching_as_code/pull/1) ([kreeuwijk](https://github.com/kreeuwijk))

## [v0.2.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.2.0) - 2020-07-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/puppetlabs/puppetlabs-patching_as_code/tree/v0.1.0) - 2020-07-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-patching_as_code/compare/362a69bc9957c1b539011eafbe2d3c725fdf8328...v0.1.0)
