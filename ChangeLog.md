# cawk Changelog

> **cawk is subject to an MIT open-source license**
> Please refer to the LICENSE file for further information
> **cawk is Copyright (C) 2024-2026 by Cedric Llorens**

## [v3.9.0] - august 2026

### Build

- Move all `Makefile.support.*.mk` files into `support/` directory for centralized organization; update `Makefile` (18 includes), `Makefile.docker` (1 include), and `docker/Dockerfile` (18 COPY directives) to reference new paths; update CLAUDE.md and README.md documentation tables
- Add FORCE=yes requirement to `clean_orig` target to prevent accidental deletion of .orig backup files; matches pattern of `clean_force` target
- Move `Dockerfile` and `dockerfile_cawk_run.sh` into a new `docker/` directory; update `Makefile.docker` to build with `-f docker/Dockerfile` (build context unchanged at repo root)
- Fix CI workflows: bump `actions/upload-artifact` v4→v5 (test.yml) and `actions/checkout` v4→v5 (release.yml) to run on Node.js 24 and clear the Node.js 20 deprecation warnings

### Docs

- Reorder Makefile.support.help.mk sections to follow the real audit workflow: SYNC → TESTS → EXCEPTIONS → CHECK → VIEW → EMAIL → POST AUDIT → BACKUP AND RESTORE → DATABASE → CATALOG; add the missing `CAWK POST AUDIT` section documenting `postaudit_run` and `postaudit_run_audit`
- Reorder README top-level `# cawk ...` action sections (sync → psirt → email → postaudit → backup/restore → catalog → Makefile) to match the reordered help output; add a dedicated `# cawk postaudit audit=AUDIT_NAME assessment` section (previously undocumented as a standalone workflow step)
- Fix README: correct NIST 800-53 family count from 17 to 16 to match report.gawk.template
- Document previously undocumented assessment report fields (number_of_confs, number_of_checks, exceptions and NIST-scoped counters) in README
- Document the `error stats` report section and the literal section headers of the assessment summary report in README
- Fix README and report.gawk.template: recalibrate error_avg_perdevice thresholds from [0,0.1)/[0.1,0.6)/[0.6,1]/>1 to [0,1)/[1,5)/[5,15]/>15 for realistic reporting

### Added

- Add `m4_cawk_exception_prefixsuffix` macro to generate exceptions with configurable field prefixes and suffixes

### Changed

- Update all `repo` exception contexts to use the new macro in inactive `dnl` examples
- Rename the NIST coverage indicator to `nist_ref_coverage` and use lowercase family names
- Move `security_info_compliance` into a dedicated information key indicators section before NIST indicators
- Rename NIST report variables from `official` to `reference` without changing coverage results
- Align README indicator formulas, fallback behavior, and NIST family output examples with the report template

---

## [v3.8.0] - july 2026

### Build

- Fix CI workflows: bump `actions/upload-artifact` v4→v5 (test.yml) and `actions/checkout` v4→v5 (release.yml) to run on Node.js 24 and clear the Node.js 20 deprecation warnings

### Fixed

- Fix sync targets: keep 3 backup archives per supplier instead of 3 globally; `sync_teststoconfs_run` and `sync_exceptionstoconfs_run` now iterate cleanup by supplier to prevent unrelated suppliers' backups from evicting each other
- Fix iptables-fwcli tests: refine NIST 800-53 mappings for chain reference validation (CM-6), default policy enforcement (SC-7), and duplicate rule detection (CM-6); improve chain name pattern matching to accept hyphens in custom chain names
- Fix security_compliance calculation: normalize divisor with weighted severity (3×high + 2×medium + 1×low) for consistent metric
- Fix error_high_ratio: exclude info findings from denominator to avoid artificially lowering the ratio
- Fix report BEGINFILE file-type detection: reset all flags in every branch to prevent misclassified counts when file order varies or a file is missing
- Fix report severity counting: read risk_level from its field instead of substring-matching the whole record, so error_line content containing severity words no longer double-counts; consolidate 16 pattern rules into the status rules
- Fix number_of_error percentage: include psirt in the denominator so pass/error/warning/psirt percentages share the same base and sum to 100%
- Remove dead code in report: unused tests[] array and is_covered variable
- Fix global_snmpforbidcommunity_notset.6wind-linux: quote risk_level "high" in pass print_err (unquoted variable produced an empty risk field)

### Changed

- Fix lineaux_aclin_set.cisco-ios: treat `transport input none` and `no exec` as a validated exception (aux port disabled for management, so an inbound ACL is not required) to avoid false-positive errors
- Fix lineaux_aclout_set.cisco-ios: treat `transport output none` and `no exec` as a validated exception (aux port disabled, so an outbound ACL is not required) to avoid false-positive errors
- Fix linevty_aclin_set.cisco-ios: treat `transport input none` and `no exec` as a validated exception (vty line disabled, so an inbound ACL is not required) to avoid false-positive errors
- Fix linevty_aclout_set.cisco-ios: treat `transport output none` and `no exec` as a validated exception (vty line disabled, so an outbound ACL is not required) to avoid false-positive errors
- Fix lineaux/linevty aclin/aclout tests for cisco-xe: apply the same disabled-port/line validated exception (`transport input/output none`, `no exec`) as cisco-ios to avoid false-positive errors
- Fix line_aclin/line_aclout tests for cisco-xr: treat `transport input none` / `transport output none` as a validated exception; `no exec` is intentionally omitted as it does not exist in IOS XR
- Centralize severity weights (high=3, medium=2, low=1) as named variables in report indicators
- Recalibrate error_avg_perdevice rating scale to realistic bands (0-1/excellent;1-5/good;5-15/average;15+/critical); previous scale flagged nearly all real assessments as critical

### Added

- Add security_info_compliance metric: separate indicator for informational findings (no artificial score inflation), labeled informational only without compliance rating scale

### Docs

- Add exact security indicators formulas to README: security_compliance, security_info_compliance, error_avg_perdevice, and error_high_ratio with precise mathematical expressions and interpretation scales
- Add "Understanding Assessment Reports" guide: interpret four security indicators together and benchmark compliance posture
- Add detailed "Report Breakdown Details" section: explain per-risk-level statistics and what each metric reveals about infrastructure security
- Add NIST 800-53 coverage explanation with all 17 family names, codes, and example controls; clarify family-level vs overall coverage metrics
- Add "Deadbeef Concept Clarification" section: explain stale configuration detection, two operating modes (include/exclude), and practical use cases
- Add "Supported Suppliers" section: list all 15 network platforms and directory organization pattern
- Add "Test Metadata Tags Reference": complete guide to required @tags, format rules, multi-aspect tests, and example test header

### Tests

- Add `global_stealthrule_set` test for checkpoint-fwcli: verify a stealth rule dropping traffic destined to the gateway itself is present in the rulebase (NIST SC-7)
- Add `global_telnet_notset` test for checkpoint-fwcli: verify telnet management access is disabled per CIS Gaia benchmark, cleartext credentials must not be used (NIST SC-8)
- Add `global_inactivitytimeout_set` test for checkpoint-fwcli: verify clish inactivity-timeout and WebUI session-timeout are set, warn above CIS recommended 10 minutes (NIST AC-11)
- Add `global_remotesyslog_set` test for checkpoint-fwcli: verify a remote syslog server is configured for centralized log retention (NIST AU-4)
- Add `global_adminlockout_set` test for checkpoint-fwcli: verify Gaia password-controls deny-on-fail lockout is enabled, disabled by default it allows unlimited brute-force attempts (NIST AC-7)
- Add `global_adminlockout_set` test for fortinet-fortios: verify admin account lockout threshold is configured to safe value (1-10 attempts) to prevent brute-force attacks (NIST AC-7)
- Add `global_admintimeout_set` test for fortinet-fortios: verify idle admin session timeout is configured to safe value (1-30 minutes) to prevent unattended session exploitation (NIST AC-11)
- Add `global_httpsonly_set` test for fortinet-fortios: verify HTTPS-redirect is enabled and HTTP management is disabled to protect credentials in transit (NIST SC-8)
- Add `global_tlsminversion_set` test for fortinet-fortios: verify SSL/TLS minimum version is set to TLSv1.2+ to prevent downgrade attacks and known vulnerabilities (NIST SC-13)
- Add `global_trusthost_set` test for fortinet-fortios: verify every admin account restricts management access with trusthost per CIS FortiGate benchmark (NIST AC-17)
- Add `global_passwordpolicy_set` test for fortinet-fortios: verify system password-policy is enabled with minimum-length 8 or more (NIST IA-5(1))
- Add `global_chaindefref_set` test for iptables-fwcli: verify custom chains are defined and referenced correctly to detect dead code and invalid references
- Add `global_defaultpolicy_set` test for iptables-fwcli: verify default drop policies are set on INPUT, FORWARD, and OUTPUT chains to enforce implicit deny
- Add `global_duplicaterule_notset` test for iptables-fwcli: detect duplicate rules that indicate configuration drift or errors
- Add `global_icmpratelimit_set` test for iptables-fwcli: verify ICMP echo-request is rate-limited when accepted to prevent DoS attacks
- Add `global_synfloodprotect_set` test for iptables-fwcli: verify syn flood protection via limit/hashlimit on syn packets or SYNPROXY target (NIST SC-5)
- Add `global_scrub_set` test for packetfilter-fwcli: verify traffic scrub normalization with fragment reassembly is configured
- Add `global_antispoof_set` test for packetfilter-fwcli: verify antispoof rules are configured to prevent IP spoofing
- Add `global_statelimits_set` test for packetfilter-fwcli: verify state and fragment table limits are configured to prevent exhaustion attacks
- Add `global_urpffailed_set` test for packetfilter-fwcli: verify unicast reverse path forwarding check blocks spoofed packets
- Add `global_sshratelimit_set` test for packetfilter-fwcli: verify ssh pass rules use max-src-conn-rate with an overload table to block brute-force sources (NIST AC-7)

---

## [v3.7.0] - july 2026

### Performance

- Precompute catalogs once in `check_repo`/`check_run`, reducing from 32 sub-makes to 2 (~2.8x speedup)

### Added

- Add `CO_AUTHOR` parameter to `gitcommit` target in `Makefile.support.git.mk` to support flexible co-author attribution in commits (usage: `gmake gitcommit FORCE=yes CO_AUTHOR="Name <email@github.com>"`)

### Fixed

- Fix run-audit auto-discovery in containers: add `find -L` so `catalog_build`, `create_audit`, `delete_audit`, `list_audit`, audit backup, and `exceptions_build` find `run_*` audits when `tests`/`exceptions` are symlinks to the persistent volume
- Fix `check_run` shell syntax error in supplier+audit cases caused by inline Makefile comments breaking `if/fi` blocks
- Fix `database_email_add`/`update` shell syntax error by restructuring `ifeq`/`endif` to shell `if`/`fi` blocks
- Fix `Makefile.docker info` target: display actual cawk version instead of Docker version
- Fix `Makefile.docker check-system` target: wrap shell variable assignments in bash subshell to prevent variable scope issues
- Fix `Dockerfile`: add missing `COPY Makefile.docker` directive for complete image build
- Fix `dockerfile_cawk_run.sh`: prevent symlink creation failure by checking if link already exists before ln -s
- Fix `Makefile.docker remove-image-alpine` target: correct message from "remove cawk image" to "remove alpine image"
- Fix `Makefile.docker cawk-check` target: check if container exists/running instead of recreating it, create logs directory before writing
- Fix `Makefile.docker info` target: improve version display with "Version: " prefix and add docker images/containers info
- Fix `view_repo_error` and `view_run_error` targets: use aggregated assessment.all.csv instead of non-existent per-supplier CSV files

### Enhancement

- Simplify `catalog_exceptions_repo` to display exceptions from source files grouped by metadata
- Improve `cawk_check_system` output: add tool categorization (essentials/support/optional), summary count, and visual indicators (✅/❌)

### Code Quality

- Standardize `${var}` to `$(var)` syntax across all Makefile.support.*.mk files
- Refactor `ifeq`/`endif` patterns to runtime shell conditions in database, audit, archive, and other targets

### Tests

- Add `aaa_userclass_notset` test for juniper-junos: verify users have an assigned class
- Add `aaa_classpermissions_notset` test for juniper-junos: verify login classes have explicit permissions
- Add `aaa_classdefref_set` test for juniper-junos: verify login classes are defined and referenced
- Add `tcl_script_notset` test for cisco-ios/xe: verify TCL scripts are forbidden
- Add `global_scrub_set` test for packetfilter-fwcli: verify traffic scrub normalization with fragment reassembly is configured
- Add `global_antispoof_set` test for packetfilter-fwcli: verify antispoof rules are configured to prevent IP spoofing

### Build

- Rename Docker script `cawk_docker_run.sh` to `dockerfile_cawk_run.sh`
- Add missing Makefile.support.*.mk files and documentation files to Dockerfile COPY directives for complete image build
- Add git package to Alpine Dockerfile to prevent git-related warnings at container startup

### Build System Refactor

- Split monolithic Makefile into 17 modular `Makefile.support.*.mk` files (phases 1-3)
- Add standardized headers to all assessment macros in Makefile.support.mk
- Integrate assessment macros into check_repo/check_run cases, eliminating inline duplication
- Add `cawk_deadbeef_scan` foreach-safe macro for per-device deadbeef scanning
- Add `cawk_test_gen_parallel` foreach-safe macro for parallel-mode test execution
- Normalize parallel-mode execution blocks to fix drift across the 6 variants
- Decentralize `.PHONY` declarations into each support file
- Consolidate `cawk_deadbeef_idx` into unified `cawk_deadbeef_scan` macro
- Update CLAUDE.md with complete build system architecture

### Database Management

- Add `sort_database_file` macro to enforce lexicographic ordering on all database targets

### CI/CD & Git Automation

- Add GitHub Actions workflow for automated `gmake check` on every push
- Install all cawk runtime dependencies in CI (gawk, make, m4, coreutils, diffutils, grep, sed)
- Enhance `gitinstallcicd` to copy all `.yml` workflows from `cicd/` to `.github/workflows/`

### Documentation

- Add Makefile section in README describing the modular split into 17 support files

---

## [v3.6.0] - June 2026

### Makefile
-- structure --
- Improve readability and fix minor bugs
- Start splitting the Makefile into several parts for enhancement purposes
-- build --
- exceptions_build, exceptions_build_run, exceptions_build_repo now call exceptions_build_run (without audit) to handle exceptions/run/ in addition to named audits
- catalog_build, catalog_build_run, catalog_build_repo now call catalog_build_run (without audit) to handle tests/run/ in addition to named audits
-- sync --
- sync_teststoconfs_run, sync_exceptionstoconfs_run: auto-cleanup old zz.sync.save.* (keep only 3 newest) to prevent disk space accumulation
- sync_teststoconfs_run: rename test directories to zz.sync.save.*.YYYY-MM-DD instead of removing them (preserve for audit trail)
- sync_exceptionstoconfs_run: rename exception files to zz.sync.save.*.YYYY-MM-DD instead of removing them (preserve for audit trail)
-- catalog --
- catalog_exceptions_repo and catalog_exceptions_run: search suppliers in confs/ directories instead of exceptions/

### Makefile.support.mk
- Add documentation headers to Makefile.support.mk: clarify pattern rules (no .PHONY required), organize into logical sections (version, directories, suppliers, compilation, options, reporting) for improved maintainability
- Add compilation validation to Makefile.support.mk: detect silent empty/malformed .gawk files by verifying file is non-empty and has shebang
- **Phase 2.5 (Refactoring):** Add three reusable macros for check_repo/check_run duplication reduction: `cawk_summary_scope` (exception filtering + report generation + catalog), `cawk_deadbeef_idx` (deadbeef CSV + indexing), `cawk_test_execution` (test discovery + execution); eliminates ~400 LOC duplication across 12 cases

### Makefile
- **Phase 2A (Build System Optimization - Complete):** Refactor all 4 check_repo cases (no supplier/supplier × no parallel/parallel) to use new `cawk_summary_scope` macro; eliminates 64 LOC of duplicated exception filtering + report generation + catalog code; also fixes ECHO newline issue in parallel mode (was using `\n` without `-e` flag)
- **Phase 2B (Build System Optimization - Extensive):** Refactor 7 of 8 check_run cases (all non-audit paths + Cas 7 parallel supplier) to use `cawk_summary_scope` macro; eliminates ~150 LOC; remaining 4 audit cases (Cas 2, 4, 6, 8) preserve conditional `if [ -d ... ]` guards for future refactoring
- **Bug Fix (Macro Integration):** Fix shell syntax error in refactored foreach loops: change trailing `\` (Makefile line continuation) to `;\` (shell statement terminator) in macro calls within `$(foreach)` blocks to generate valid shell commands

### Makefile.cawk.version
- Improve documentation in Makefile.cawk.version: add detailed help for install/reinstall/update operations with usage examples, clarify error messages, add success confirmation output ([Makefile.cawk.version](Makefile.cawk.version) lines 1-49)
- Fix line endings: Makefile.cawk.version had CRLF line terminators (likely from Windows editing); normalized to LF. Added [.gitattributes](.gitattributes) with `* text=auto eol=lf` to enforce LF normalization across all text files and prevent future CRLF drift

### Community & Contribution Files
- Add community contribution guidelines and templates: created [CONTRIBUTING.md](CONTRIBUTING.md) (migrated from PR.howto.md, enhanced with code style guidelines and testing instructions), [SECURITY.md](SECURITY.md) (responsible disclosure policy for security vulnerabilities), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant), [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) (PR checklist), [.github/ISSUE_TEMPLATE/bug_report.md](.github/ISSUE_TEMPLATE/bug_report.md) and [.github/ISSUE_TEMPLATE/feature_request.md](.github/ISSUE_TEMPLATE/feature_request.md) (issue templates for bug reports and feature requests). Modernized [README.md](README.md) community section to link to CONTRIBUTING.md and other governance files. Deleted PR.howto.md (content migrated to CONTRIBUTING.md)

### Makefile.docker
- Improve structure of Makefile.docker: reformatted .PHONY into grouped logical functions (help, build, volumes, images, cleanup), enhanced header documentation, add section comments for container/volume/system targets

### Scripts
- Fix catalog_build_exceptions_db.gawk: remove dependency on m4_cawk_exception macro — exceptions are now compiled based on metadata (@exception_id) alone
- Add print_err() field validation to check_test.gawk: validate both risk_level (4th arg: high, medium, low, info) and status_code (5th arg: pass, error, warning, psirt) at `gmake tests_check` time; captures errors even with concatenated message expressions

### Tests
- Add PSIRT test directories and templates for all suppliers
— Correct NIST 800-53 reference in PSIRT tests: replace AU-12 (audit) with SI-2 (flaw remediation)
- Add global_banner_set test (AC-8, high) to 4 suppliers missing it: juniper-junos, huawei-vrp, nokia-sros, ekinops-oneos
- Add new paloalto-panos tests: aaa_authprofile_set (IA-2, high), login_banner_set (AC-8, medium)

---

## [v3.5.0] - May 2026

### Package
- cawk is now managed under Claude Code

### Tests
- Update tests regexes for suppliers: cisco-ios, cisco-xe, cisco-xr
- Update all tests to include comprehensive @metadata for test catalog generation (db_info.txt)
  - @test_name, @supplier, @purpose, @description, @actions, @nist800-53_ref, @authors
- Add new juniper-junos tests:
  - routing_communitydefref_set
  - routing_ribgroupdefref_set
  - firewall_familyinet_set
  - syslog_host_set
  - snmp_v3viewdefref_set
  - services_sshv1_notset
  - ntp_restrict_set

### Makefile
- Update tests_run_copy and tests_run_audit_copy targets
- Update catalog targets and add new catalog targets
  - `catalog_build`, `catalog_repo`, `catalog_run`, etc.
  - See README for further information
- Add new exceptions targets and information banner
  - `exceptions_build_repo`: build exceptions from repo .m4 files
  - `exceptions_build_run`: build exceptions from run .m4 files (or run_AUDIT_NAME)
  - `exceptions_run_copy audit=AUDIT_NAME`: copy exceptions from repo to audit (no overwrite)
  - `exceptions_run_audit_copy`: copy exceptions from repo to all named audits
- Add exception database build and display targets
  - `exceptions_build`: rebuild database/db_exception.txt from all .m4 files
  - `exceptions_build_repo`: build exception database for repo/ and run/
  - `exceptions_build_run audit=AUDIT_NAME`: build for specific audit
  - `catalog_exceptions_repo`: display exceptions by supplier for repo
  - `catalog_exceptions_run [audit=AUDIT_NAME]`: display for run or specific audit
- Add NIST 800-53 compliance coverage targets
  - `nist_coverage_official`: display official NIST 800-53 controls with coverage metrics
  - `nist_coverage_repo`: calculate coverage percentage for repo assessment
  - `nist_coverage_run [audit=AUDIT_NAME]`: calculate coverage for run or named audit
- Integrate exceptions_build into create_audit and delete_audit workflows
- Extend create_audit and delete_audit with supplier parameter for incremental audit management
  - `create_audit audit=AUDIT_NAME`: create full audit (all suppliers)
  - `create_audit audit=AUDIT_NAME supplier=SUPPLIER`: add supplier to existing audit
  - `delete_audit audit=AUDIT_NAME`: delete full audit
  - `delete_audit audit=AUDIT_NAME supplier=SUPPLIER`: remove supplier from existing audit
- Add sync targets to maintain test/exception scope consistency with configurations
  - `sync_exceptionstoconfs_run audit=AUDIT_NAME`: remove exceptions for suppliers without confs in run_AUDIT_NAME
  - `sync_exceptionstoconfs_run_audit`: sync exceptions for all named audits

### Common
- Update report.gawk.template, report_sumjson.gawk.template to manage compliance framework indicators
- See README for further information

### NIST 800-53 Compliance
- Add database/db_nist800-53.txt: official NIST 800-53 controls reference
  - Format: nist_id;category;description;applicable_suppliers
  - NIST controls applied during assessment reporting phase
  - Used to calculate nist_ref_coverage percentage and compliance metrics
- Control coverage mapping:
  - database/db_nist800-53.txt — source of official NIST 800-53 controls (one entry per control ID)
  - Controls mapped to applicable suppliers (e.g., cm-7 applies to all network device types)
  - Coverage percentage calculated as: (tests mapped to NIST controls / total NIST controls) × 100%
- Integration with assessments:
  - NIST coverage automatically included in summary reports (.all.*.txt)
  - Coverage percentage displayed as compliance framework indicator
  - Allows tracking NIST 800-53 compliance progress across assessments

### Exceptions Database
- Add database/db_exception.txt: centralized exception rules repository
  - Format: audit;supplier;exception_id;approver;date;reason
  - Stores exception metadata for audit tracking and approval history
  - Exception matching logic defined in source .m4 files (device/test/pattern regexes)
- Exception sources:
  - exceptions/repo/*.m4 files — source definitions with metadata (@exception_id, @approver, @date, @reason)
    - Contains m4_cawk_exception() macros with device, test_name, error_pattern matching rules
  - exceptions/run/*.m4 files — editable copy for default assessment
  - exceptions/run_`audit`/*.m4 files — per-audit custom exceptions
- Automatic integration:
  - exceptions_build triggered automatically by `create_audit` and `delete_audit` workflows
  - Ensures database/db_exception.txt stays synchronized with audit lifecycle
  - Exceptions applied to summary and final reports (.all.*.csv, .all.*.json)

---

## [v3.4.0] - March 2026

### Makefile
- (beta) Environment variable CAWK_SYSNAME for special common functions
  - Use database/common/special_common.gawk.template instead of common/common.gawk.template
- New TMP_ASSESSMENT_FILES variable to clean intermediate supplier files (default: yes)
- Performance enhancements

### Package Integrity
- Additional sha521sum check to verify package integrity before assessment

### Makefile.docker
- Updated to inherit variables from Makefile.support.mk

### Tests
- Review all existing tests for ACL consistency
- Add new suppliers: packetfilter-fwcli, ekinops-oneos
- Thoroughly review ACL consistency library (common/common_hypercube-lib.gawk.template)

---

## [v3.3.0] - January 2026

### Makefile
- Add new supplier: ekinops-oneos
- New target `sync_teststoconfs_run`: sync tests to confs for audit=AUDIT_NAME
- New target `sync_teststoconfs_run_audit`: sync tests to confs for all audits
- Optimize Makefile to avoid Unix shell maximum line length

### Tests
- Add new tests for iptables-fwcli and ekinops-oneos (new authors)

### Makefile.cawk.version
- Specific Makefile for version package management
- Must be located in parent directory of cawk installations

---

## [v3.2.0] - December 2025

### Makefile
- New PSIRT variable for conditional test compilation
  - `gmake check_run audit=<AUDIT_NAME> PSIRT=yes`: only PSIRT tests
  - `gmake check_run audit=<AUDIT_NAME> PSIRT=no`: all tests (default)
- Fix bug in database.repo copy

### Docker
- Add 3 new files for cawk container:
  - Makefile.docker
  - Dockerfile
  - cawk_docker_run.sh
  - See README for details

---

## [v3.1.0] - October 2025

### Makefile
- New script: database_sync_psirt.sh in database/scripts
- New target `sync_psirt`: build PSIRT inventory
- New target `database_repo_copy`: update database with missing files
- Fix bug with $(ECHO) -e command (portability)
- Fix backup_audit_run find command (-type f -o -type d portability)
- Update database_sync with regex_path_exclude option

### Tests
- Add advanced PSIRT test code:
  - Match line, block, OS version, etc.
  - Built over common/test_generic_psirt.gawk.template v1.0
  - Suffix: .gawk.include
  - One advanced PSIRT code for cisco-ios, cisco-xe, cisco-viptela, cisco-xr
- username test now available for cisco-xe
- All cisco-ios tests now available for cisco-xe

---

## [v3.0.0] - October 2025

### Makefile
- Support advanced PSIRT vulnerability checks (future release)
- Support Docker container deployment (future release)
- Enforce Makefile controls during processing
- EGREP variable points to `grep -E` instead of `egrep`
- New target `clean_archive_older`: remove archives older than ARCHIVE_OLDER_DAYS
- Update `sync_run` with OS supplier regex matching

### Tests
- banner tests available for all Cisco suppliers
- enable password tests available for all Cisco suppliers
- logging tests available for all Cisco suppliers

---

## [v2.9.0] - September 2025

### Makefile
- Improve test execution: multiple config files per test run
- Option TEST_EXE in Makefile.support.mk controls this behavior
- Performance improvements (.INTERMEDIATE and *.swap)
- New target `gmake version`: display current version
- New targets: `gmake tests_check`, `gmake tests_check_nok`

### Tests
- Add banner test for cisco-ios (replicate to other scopes in future)
- Update crypto algorithm tests across all suppliers
- Fix inconsistent test output names

### Common
- check_test.gawk.template validates test consistency and format compliance

---

## [v2.8.0] - July 2025

### Makefile Reports
- Include number of exceptions in summary report
- Include number of deadbeef configurations
- Attach summary as file in email_send target
- Simplify view_error and view_run output
- Check to avoid copying existing files in run_audit

### Tests
- Update for cisco-ios, cisco-xe, cisco-cedge: default commands (hidden)
- Update for cisco-ios, cisco-xe: line aux tests (modem support)

### Common
- Review timeline reporting code for performance

---

## [v2.7.0] - June 2025

### Makefile Reports
- Rename ".all.full." to ".all." in final reports
- Build *.idx (index of configurations)
- Build new final PSIRT report (.all.psirt.)
- Build timeline reports (for PowerBI, Grafana, etc.)
  - Includes timestamp header (year, month, day, week)
- Deadbeef concept activation in Makefile.support.mk or via `gmake ... DEADBEEF=yes`
- Device considered deadbeef if config older than DEADBEEF_THRESHOLD_DAYS (default: 30 days)

### Makefile Backup
- Enforce logs/run_audit/AUDIT_NAME backup in gzipped file (migration support)
- Use multiple finds for test copying (system portability)

### Common
- Update summary format for better readability

### Tests
- Update 6wind-linux tests (enhanced output)

---

## [v2.6.0] - May 2025

### Tests
- Update cisco-ios, cisco-xe, cisco-cedge: acls*defref* tests
- Update cisco-ios, cisco-xe, cisco-cedge, cisco-xr: routing*defref* tests
- Update juniper-junos: filter*defref* tests

### Common
- Add "error stats" section: sorted list of frequent test errors by risk level

### Makefile
- Update create_audit and delete_audit targets
- Add new status code: psirt
- New targets:
  - `tests_run_copy audit=AUDIT_NAME supplier=SUPPLIER_NAME`
  - `tests_run_audit_copy` (all suppliers, all audits)
  - `database_postaudit_(add,del,update)` (post-assessment tasks)
  - `migrate file=BACKUP_PATH_FILE` (version migration)

---

## [v2.5.0] - April 2025

### Tests
- Add new scope: 6wind-linux
- Review risk level and status codes for all defref tests

### Makefile
- Full reporting for all suppliers (in addition to per-supplier)
- Generate cawk msg for missing confs/tests (allows cleanup)
- New targets for email notifications: `database_email_(add,del,update)`
- New targets: `email_send(_audit)?`
- Update `gmake database_sync_(add,update)` with scope option
- Fix bugs in view targets

### Makefile.support.mk
- JSON var set to "no" by default (set to "yes" for JSON reports)

### Directories
- Add log directory for cawk logs

---

## [v2.4.0] - March 2025

### Tests
- Update and add for: packetfilter-fwcli, iptables-fwcli, checkpoint-fwcli
- Add new supplier: cisco-xr

### Makefile
- New sync targets: `sync_run`, `sync_run_audit`
- New backup targets: `backup_run`, `backup_run_audit`
- New restore targets: `restore_run`, `restore_run_audit`
- New database management targets: `database_view`, `database_sync_(add,del,update)`

### Directories
- New directory: `database/` for cawk options in flat files
- New directory: `backup/` for backup/restore data

---

## [v2.3.0] - March 2025

### Tests
- Add new supplier: cisco-xe
- Add SNMP v3 tests for all suppliers:
  - cisco-ios, cisco-cedge, cisco-xe, cisco-viptela, nokia-sros, paloalto-panos, huawei-vrp, fortinet-fortios, juniper-junos

### Reports
- Compute security Compliance percentage (0-100%, 100% best)
- Compute average errors per device (0 is best)
- Auto-generate JSON from CSV and TXT reports

### Makefile
- Auto-build tar.gz in archives directory
- New targets: `clean_report_*`, `clean_archive_*`

---

## [v2.2.0] - February 2025

### Makefile
- New target: `run_audit` (run all assessments with AUDIT_NAMEs)

### Tests
- Review all purpose/author sections
- Add LLDP/CDP tests for all suppliers:
  - cisco-ios, cisco-cedge, cisco-viptela, nokia-sros, paloalto-panos, huawei-vrp, fortinet-fortios, juniper-junos
- Add new suppliers: packetfilter-fw, iptables-fw, checkpoint-fw
- New authors: Maxime Souris, Adrien Lebout, Pierre Bertrand, Lucas Vanhaaren, Gautier Goncalves, Wael Elsingaby

---

## [v2.1.0] - January 2025

Stabilized release from v2.0.0 train

- Update date 2024-2025
- Change checkdiff output for system portability
- Add .gitkeep in all empty directories
- Enforce run repository as full copy of repo
- New target: gitcheckdist (counter-measures checks before github push)
- Add PR submission procedure

---

## [v2.0.1] - December 2024

- Add .gitkeep to reports/repo and reports/run

---

## [v2.0.0] - November 2024

Major update: new AUDIT-NAME assessment workflow

### Common
- Add number_of_pass_error in summary report
- Review gmake command output and help

### Makefile
- Complete review of Makefile structure
- Use variables for all core directories
- Create/delete/list assessments: `create_audit`, `delete_audit`, `list_audit`
- New targets support audit=AUDIT_NAME

### Directory Structure
- Reorganize confs, tests, exceptions, reports

### Tests
- Add new tests across all suppliers

---

## [v1.9.0] - October 2024

### Common
- Fix small bugs
- New target: `gmake common` (list available functions)

### Tests
- Add new tests for all suppliers
- Review paloalto-panos conf and update tests

---

## [v1.8.0] - August 2024

### Common
- Fix bugs and output issues
- Include M4 preprocessing for exceptions
- Support .template and .m4 suffixes
  - .m4 uses M4 preprocessing for block hierarchy

### Tests
- Add new supplier: cisco-cedge
- Add new tests for cisco-ios, cisco-cedge, cisco-viptela (.m4 extension)

---

## [v1.7.0] - June 2024

### Common
- Build exceptions directory (empty per supplier)
- Update Makefile for exception reporting

### Tests
- Run and fix bugs on all suppliers

---

## [v1.6.0] - June 2024

### Common
- Migrate firewall rules library to common
- Add 'research' supplier for development
- Add risk level: info
- Update reporting for info level and sorting

### Tests
- Add cisco-ios simple ACL tests (info level)
- Add huawei-vrp ACL tests (partial)
- Add NTP tests for: cisco-ios, juniper-junos, huawei-vrp, cisco-viptela, nokia-sros

---

## [v1.5.0] - May 2024

### Common
- New target: `view_error` (only view assessment errors)

### Tests
- Review and fix bugs

### Future
- Firewall rules analysis (redundant/inconsistent rules)
- Cisco-ios scope progress

---

## [v1.4.0] - April 2024

### Common
- Remove init from generated parallel Makefile
- Enhance reporting: high/medium/low % with float
- Remove colors, add OK/NOK for portability

### Tests
- Add tests for: cisco-ios, juniper-junos, huawei-vrp, cisco-viptela, nokia-sros

---

## [v1.3.0] - March 2024

### Makefile
- Add Makefile.support.mk for make options
- Enable parallel mode
- New target: `system` (check system readiness)

### Tests
- Add tests for all suppliers
- Add supplier: cisco-viptela

---

## [v1.2.0] - March 2024

### Makefile
- Review catalog and test output

### Tests
- Update all test purposes
- Add tests for all suppliers
- Add supplier: paloalto-panos

### Future
- Generate parallel Makefile (stability, race condition management)

---

## [v1.1.0] - February 2024

### Makefile
- Add new suppliers with OS suffix
- Add per-scope view with `supplier=` variable

### Tests
- Add tests for existing suppliers
- Add supplier: nokia-sros

---

## [v1.0.0] - February 2024

Initial release

- Basic tests for: cisco-ios, huawei, fortinet, juniper-junos
- Basic reporting
- Fully automated with gmake
