<p align="left"><img src="docs/logo/logo-cawk.svg" width="200" alt="cawk"></p>

# cawk Changelog

> **cawk is subject to an MIT open-source license**
> Please refer to the LICENSE file for further information
> **cawk is Copyright (C) 2024-2026 by Cedric Llorens**

## [v5.0.0] - october 2026 

> **v5.0.0 is a major release: it introduces three new concepts, the config collector (`scp`/`rsync`), the standalone HTML report (`HTML=yes`) and the configuration censor (`censor_*`).**

### Tests

- Fix `acl_configconsistency_set` of every supplier: report inconsistent/redundant rules as `info;warning` instead of `info;error`, in `cawk_add_hypercube_rules()`
- Fix `CVEyyy_xxx_psirt`/`CVEyyy_xxxm4_psirt` of every supplier: append `FAKE` to the first line and block start patterns so the templates never match a real configuration
- Fix `int_ipv6redirects_notset.cisco-ios`/`cisco-xe`/`cisco-xr`: flag the explicit `ipv6 redirects` command instead of the absence of `no ipv6 redirects`
- Fix `routing_defref_set.cisco-ios`/`cisco-xe`/`cisco-xr`/`cisco-cedge`: accept the plural `prefix-lists` form in the `match ip address prefix-list` pattern, the generic `prefix(-list)` pattern and the `$i == "prefix-list"` field check
- Fix `routing_defref_set.cisco-ios`/`cisco-xe`/`cisco-xr`/`cisco-cedge`/`cisco-sdnios`: loop over all `$5`-`$NF` prefix-list names in `match ip address prefix-list(s)` instead of only `$5`
- Fix `acl_defref_set.cisco-ios`/`cisco-xe`/`cisco-cedge`/`cisco-sdnios`: exclude the plural `prefix-lists` form from the `match ip address` ACL reference check, matching `prefix-list`
- Add `routing_defref_set.cisco-sdnios`, ported from `cisco-ios`
- Add `int_ipv6redirects_notset.cisco-cedge`, ported from `cisco-ios`
- Fix `ntp_ip_set.cisco-xr`: accept the one-line `ntp server [vrf VRF] IP` form besides the `ntp` block form
- Fix `int_lldp_notset.fortinet-fortios`: only `set lldp* (enable|status)` is an error, `set lldp* disable` is no longer a false positive
- Fix `global_lldp_notset.fortinet-fortios`: only `set lldp* (enable|status)` is an error, `set lldp disable` is no longer a false positive
- Fix `int_directbroadcast_notset.huawei-vrp`: anchor `direct-broadcast` with `^ ` in the interface block patterns
- Fix `ssh_setup_set.fortinet-fortios`: `set admin-ssh-v1 enable` is an error, any other enabled `admin-ssh-*` is a pass
- Fix `ntp_accessgroup_set.cisco-xr`: accept the one-line `ntp access-group ...` form besides the `ntp` block form, fix the error message (`<ntp access-group>`)
- Change `test_generic_psirt.gawk.template` risk levels, all kept in the `psirt` status: `high` vulnerable, `low` OS matched but not exposed, `info` not vulnerable, `medium` skipped (no information); the 15 psirt `.include` declare `@risk_level : high | medium | low | info`
- Fix `global_vardefref_set.packetfilter-fwcli`: report the first reference line of an undefined variable (`line_nb` was a space-separated list such as `35 36`)
- Add `acl_configconsistency_set.juniper-junos` (10th supplier, `repo` only): `firewall family inet filter` terms, terms with `except`, prefix-list, tcp flags or no final action are not assessed
- Fix `test_generic_psirt.gawk.template`: a vulnerable (`high`/`psirt`) result reports the first matched line (`line_nb` was the last line of the configuration)
- Add `CVEyyy_xxx_psirt.cisco-ios` psirt template, copied from `CVEyyy_xxx_psirt.cisco-cedge` and adapted to `cisco-ios`
- Add `conf_acl_consistency` (11 errors, 7 pass) and `conf_acl_consistency_big` (~1600 lines, 55 errors, 35 pass) demo confs for `juniper-junos`
- Add `validate/collect/run.sh` and 100 non-regression cases of the collectors and of their link with the sync (`gmake check_collect`, no network)
- Remove dead code (`device_config_file`, `block_matched_lines`, `config_psirt_block_patterns_matched`) from `test_generic_psirt.gawk.template`
- Fix `test_generic_psirt.gawk.template` silently disabling a psirt test on a gapped `LINE`/`BLOCK` index, an undeclared or invalid `LOGIC` or an invalid regex (now one `error` line per configuration)
- Fix `test_generic_psirt.gawk.template` inventory lookup (regex and shell on the file name): exact match, lazy load keeping only the configurations of the run, no `grep`/`test -f` per file
- Fix `test_generic_psirt.gawk.template` block parsing (start line counted as an inner line, `break` on the first matching pattern), inventory entries with fewer than 3 fields (double message) and chassis containing spaces
- Cache the `LOGIC` evaluation of `test_generic_psirt.gawk.template` per distinct expression (one `awk` process instead of one per configuration)
- Add `validate/psirt/run.sh` and 11 non-regression cases of the psirt engine
- Add `OS_CMP` version comparisons (`eq`, `lt`, `le`, `gt`, `ge`, `between`, optional `platform` regex) to `test_generic_psirt.gawk.template`, with `version_cmp()` and `check_psirt_config()` validation
- Add `validate/psirt/12_os_cmp`, `13_os_cmp_bad_operator` and `14_os_cmp_bad_range` non-regression cases of `OS_CMP`
- Add `CVEyyy_xxxm4_psirt.<supplier>.gawk.include.m4` demo for the 15 psirt suppliers, same results as `CVEyyy_xxx_psirt` (cisco, juniper, fortios, panos, sros, 6wind, ekinops, iptables use `psirt_os_between`)
- Add `m4/cawk_psirt.m4`: `psirt_begin`/`psirt_end`, `psirt_device`, `psirt_os`, `psirt_os_(eq,lt,le,gt,ge,between)`, `psirt_line`, `psirt_block`, `psirt_block_line`, `psirt_logic` with automatic indexes and named lines/blocks
- Add `validate/censor/run.sh` and 79 cases (`cases.tsv`) checking every section of `censor_regex.m4` at `CENSOR_LEVEL=internal` and `external`
- Extend `validate/censor/run.sh` with the `CENSOR_OUT_FILE`, standard output, multi-file `CENSOR_OUT_DIR` and `CENSOR_MODE=check` modes of `censor.gawk`
- Fix the 5 `int_*_notset.fortinet-fortios` tests reporting line `0` instead of the matching line
- Fix `crypto_isakmpkeyenc_set` (`cisco-ios`/`cisco-xe`/`cisco-xr`/`cisco-cedge`) reporting the isakmp key in clear: only `crypto isakmp key` is printed
- Fix `protocols_bgpgroupauth_set`/`protocols_bgpneighborauth_set.juniper-junos` reporting the authentication-key in clear: only the keyword followed by `...` is printed
- Fix `aaa_config_set.cisco-sdnios` checking `aaa new-model`, absent from this OS
- Fix `linevty_aclin_set.cisco-sdnios` requiring the `in` keyword after `access-class`
- Fix the `pass` message of `global_lldp_notset`/`global_sourcerouting_notset.fortinet-fortios` wrongly mentioning a mgnt interface
- Fix `global_lldp_notset.paloalto-panos` prefixing errors with an unset `interface`
- Add `CENSOR_CSV=yes` to `common/censor.gawk` (censors the error_line column of a csv report into `X.censored.csv`)

### Makefile

- Fix `email_send` zip failure branch (`exit 1` outside the `||` group, `mutt` never invoked)
- Fix `%.gawk.m4` and `%.gawk.include.m4` compilation rules: a failing `m4` removes the target (no more `|| true`)
- Fix `tests_check_nok` exit code: fails when a `cawk test error` is found
- Fix `archive_repo`/`archive_run` exit 1 when `tar` fails, `delete_audit` exit 1 when the audit does not exist
- Fix messages: `tests_run_copy <supplier>` space, `email_send done`, `database_email_add done`, `cawk error:` prefix in `check` and `git_branch_*_check`
- Fix `check`: remove the `delete_audit` calls on audits that do not exist
- Fix `check_supplier`: reject PSIRT_ONLY, STANDARD_ONLY, MAKE_PARALLEL, JSON, HTML, TIMELINE, CATALOG_BUILD, DEADBEEF, BADFORMAT, CRLF, TMP_ASSESSMENT_FILES not yes/no and MAKE_J, MAKE_LOAD_AVG, DEADBEEF_THRESHOLD_DAYS not a number
- Fix `%: %.m4` rule: a failing m4 stops the build and removes the target instead of leaving an empty file
- Fix `%.script: %.script.sh` rule: a failing cp is no longer masked
- Fix `catalog_exceptions_run`: read `exceptions/run` instead of `exceptions/run_run`
- Fix `create_audit audit= supplier=`: leave the databases untouched; `create_audit` skips the entries already present
- Fix `database_sync_add`/`database_email_add`/`database_postaudit_add`: refuse a duplicate and exit 1 on error
- Fix `email_send`: `dst=none` sends nothing, errors exit 1; `email_send_audit` follows `db_email.txt`
- Fix `check`: exit 1 when the checkdiff verdict is NOK
- Fix `view_repo`/`view_run`: apply `supplier=`
- Fix `RUN_DIRS`/`RUN_DIRS_FIND`/`list_audit`: audit names containing `run_` are kept whole
- Fix `*_run_audit` loops: a failing audit makes the target fail
- Fix `clean_logs_run_audit`: check FORCE=yes once
- Fix `sync_run`/`sync_psirt`/`postaudit_run`/`database_*.script`: a failing script exits 1, `sync_psirt` needs `audit=`
- Fix `sync_*_run`/`backup_run`/`restore_run(_audit)`/`postaudit_run`: errors exit 1
- Fix `backup_run_audit`: bounded `find` instead of `run_*` globs
- Fix `exceptions_run_audit`/`exceptions_build`: audits found in `exceptions/`; `exceptions_run_audit_copy` uses `reports/run_*`; `exceptions_run_copy` skips an unexpanded glob
- Fix `database_target_sh`: single definition in `Makefile.support.database.mk`
- Fix `censor_check`: unreadable file reported as such, not as a secret
- Fix `sync_cawk_conf.gawk` usage: 6 arguments

- Add `archive_run_audit` to `support/Makefile.support.archive.mk` (archives the reports of every `AUDIT_NAME`)
- Fix the end messages naming the wrong target (`sync_run`, `backup_run`, `tests_run_copy`) and the double space in the `audit=... do not exist ----` error (6 support files)
- Fix informational messages printed as `cawk error:` (deadbeef/badformat/crlf filter detection, `db_sync.txt` entry with sync path `none`), now `cawk warning:`
- Fix `check_deprecated_*` message missing the `----` suffix, `migrate` missing its `done` message, double space in `cawk version:`
- Fix `view_repo` printing a raw `cat: No such file` when the repo reports are missing, now a `cawk warning:` message
- Add `check_repo DEADBEEF=yes` and `check_repo BADFORMAT=yes` cases to `check`/`check_parallel`
- Add `email_send` attachments `assessment.all.summary.html` + zip when `HTML=yes`, `assessment.all.summary.txt` + zip otherwise
- Fix `email_send` export zip: only the `*.timeline.csv` when `TIMELINE=yes`, the plain csv (`security`, `audit`, `psirt`, ...) when `TIMELINE=no` (it held no csv)
- Fix `archive_repo`/`archive_run` archive size: only the `*.timeline.csv` when `TIMELINE=yes`, `assessment.all.summary.html` instead of the txt files when `HTML=yes` (txt fallback), as `email_send`
- Fix `gmake[1]: Entering directory` lines written into `assessment.all.csv` by `MAKE_PARALLEL=yes` under `gmake -C` (`--no-print-directory` on the `gen_cawk_makefile` sub-makes)
- Fix `create_audit`/`delete_audit` rebuilding the whole catalog (O(number of audits)) with the new `catalog_build_audit audit=AUDIT_NAME` (only the lines of that audit)
- Fix `SECRETSCAN=yes` censoring the per-supplier `assessment.<supplier>.*.csv` removed right after (only `assessment.all*.csv` when `TMP_ASSESSMENT_FILES=yes`)
- Fix `censor_line` generated as `if (line ~ /regex/) line = word` instead of a `.*`-wrapped `gensub` (about 87x faster), `.*` warning added to `censor_regex.m4`
- Add the `%.gawk: %.gawk.include.m4` rule (`m4` then `sed` into the untracked `*.gawk.include.gen` read by the engine), `SUPPLIER_INCLUDEM4_(REPO,RUN)_PSIRT_FILES` in `tests_target_(repo,run)`, `*.include.m4` excluded from `TESTS_*_PSIRT_M4`
- Add the removal of `*.gawk.include.gen` to `gmake clean` and to `.gitignore`
- Fix `check_supplier` accepting any `audit=` name: only letters, digits, `_` and `-` are allowed, enforced before `create_audit`, `delete_audit` and every `database_(sync,postaudit,email,collect)_(add,update,del)`
- Fix psirt tests not rebuilt when `test_generic_psirt.gawk.template` or `support/tests.sed` change (added as prerequisites of the `%.gawk: %.gawk.include` rule in `Makefile.support.mk`)
- Fix `sync_run` and the `check` sync fixture failing in the docker container (`confs` is a symlink to the volume, `../..` resolved physically): absolute `$(CURDIR)` paths in `Makefile.support.sync.mk` and `Makefile.support.check.mk`
- Add `TIMELINE=yes|no` option (default `yes`): `yes` writes the `assessment.all.*.timeline.csv` reports and keeps the csv they are built from; `no` skips the timeline reports
- Add `HTML=yes|no` option (default `no`) writing `assessment.all.summary.html` with the other reports of `check_repo`/`check_run`, through the `cawk_html_gen` macro
- Add `common/report_html.gawk.template` and `common/report_html.skeleton.html`: standalone high-level html report (counters only, summaries by risk, supplier and NIST control, filters, results by test, CSV export, print)
- Change the Status block chip order of the html report to Pass, Error, Warning, PSIRT, PSIRT not affected in `common/report_html.skeleton.html`
- Change the columns of the Summary by supplier, Summary by NIST SP 800-53 control and Results by test tables of the html report to Pass, Errors, Warnings, PSIRT vulnerable in `common/report_html.skeleton.html`
- Change the `vulnerable` and `not affected` words of the PSIRT labels of the html report (table headers, kpi boxes, status chips, risk summary, legend) to a smaller font in `common/report_html.skeleton.html`
- Add the Exceptions kpi box (`assessment.all.exception.csv`, as `number_of_*_exception` of the summary) as first box of the last kpi row of the html report, split by risk and following the risk, status, supplier, NIST, preset and search filters, in `common/report_html.gawk.template` and `common/report_html.skeleton.html`
- Add the Exceptions column after Errors to the Summary by risk, Summary by supplier, Summary by NIST SP 800-53 control and Results by test tables and to the CSV export of the html report in `common/report_html.skeleton.html`
- Change the tables of the html report from Summary by risk to Results by test to a smaller font, tighter padding, wrapping headers and a narrower compliance bar to fit the page width in `common/report_html.skeleton.html`
- Change the Description and Family cells of the Summary by NIST SP 800-53 control table of the html report to a smaller font and keep its column headers on one line in `common/report_html.skeleton.html`
- Change the Description and Family columns of the Summary by NIST SP 800-53 control table of the html report to a capped width (16em) so the Pass, Errors and other columns widen in `common/report_html.skeleton.html`
- Change the Test column of the Results by test table of the html report to a capped width (24em) and keep its column headers on one line, so the other columns widen in `common/report_html.skeleton.html`
- Change the numeric cells of the Summary by supplier, Summary by NIST SP 800-53 control and Results by test tables of the html report to a slightly smaller font in `common/report_html.skeleton.html`
- Add `rh_test()` and `rh_load_exceptions()` to `common/report_html.gawk.template`: the exceptions are embedded as `excs` (test, risk, status, lines) next to `recs`
- Add active demo exceptions `EXC-REPO-001` to `EXC-REPO-004` (high, medium, info, low) in `exceptions/repo/exceptions.cisco-ios.m4` and `exceptions/repo/exceptions.cisco-xr.m4`
- Change the kpi boxes of the html report to 3 rows of 3 (Devices / Checks / Compliance, Pass / Errors / Errors per device, Warnings / PSIRT vulnerable / PSIRT not affected), PSIRT not affected becoming its own box, in `common/report_html.skeleton.html`
- Add the `deadbeef`, `badformat` and `crlf` configuration counters of the scan reports to the html report data in `common/report_html.gawk.template`
- Add the Deadbeef config, CRLF config and Badformat config kpi boxes and the info count of the Errors kpi box to the html report in `common/report_html.skeleton.html`
- Add the `high` and `medium / low / info` risk levels under the values of the `PSIRT vulnerable` and `PSIRT not affected / skipped` kpi boxes and color the Errors, Errors per device and PSIRT vulnerable kpi values in red in `common/report_html.skeleton.html`
- Annotate the kpi boxes of the html report with the lines excluded by the filters (`N excluded by filters`, `N <risk> excluded`), so a 0 is never mistaken for a fact, in `common/report_html.skeleton.html`
- Uncheck the `info` risk and the `PSIRT not affected / skipped` status by default (initial state and Reset) in the html report in `common/report_html.skeleton.html`
- Always render the five status chips of the html report, even with no matching line, so `PSIRT vulnerable` (checked) and `PSIRT not affected / skipped` (unchecked) are always both present in `common/report_html.skeleton.html`
- Color the filter legends and labels (audit type, risk, status, supplier, NIST control, search) of the html report in orange in `common/report_html.skeleton.html`
- Color the kpi box titles and the section titles (Summary by risk to Reading notes) of the html report in orange in `common/report_html.skeleton.html`
- Add `LOGO_HTML` (default `docs/logo/logo-cawk.svg`) embedding the cawk logo in the header of the html report as a base64 data uri through `cawk_html_gen`
- Add the brand header of the html report (logo, `Network configuration compliance report` title, audit subtitle) in `common/report_html.skeleton.html`
- Color the kpi values of the html report in green (Devices, Checks, Pass, PSIRT not affected) and in red (Warnings), with the Deadbeef, CRLF and Badformat boxes green at 0 and red otherwise and the Compliance box on a red-to-green hue ramp (0-100%) and the Errors per device box on a green-to-red hue ramp (0 to the 15 critical threshold) in `common/report_html.skeleton.html`
- Detail every field of the `database_view`/`database_view_(sync,collect,email,postaudit)` header with its possible values and an example (scp and rsync collectors from a central unix/linux system)
- Add `support/Makefile.support.collect.mk` with `collect_run`, `collect_run_audit`, `database_collect_(add,update,del,sync)` and `check_collect`
- Add `COLLECT=yes|no` option (default `no`) making `sync_run` run `collect_run` first, and clean `confs/collect_<audit>`, `db_collect.txt` and the collect scope in `delete_audit`
- Add the default `db_collect.txt` entry (`collector=none args=none`) to `create_audit` (kept if present), replaced by `database_collect_add`/`update` and ignored by `collect_run`
- Add `confs/collect_*/` to `.gitignore`
- Add `database_view_collect`, show `db_collect.txt` (before `db_sync.txt`) in `database_view` and print the succinct field format of each database before its separator in `database_view`/`database_view_*`
- Fix `gen_cawk_makefile(.psirt).gawk` so concurrent generated makefiles no longer remove each other's temporary files (one `mktemp -d` directory per makefile instead of `rm -f tmp/tmp*`) and split the work per (configuration chunk, test) for real parallelism
- Speed up `check_repo`/`check_run` in parallel mode (`MAKE_PARALLEL=yes`) by running the suppliers concurrently: `check_repo` 13-15 s to 5.9 s, identical reports
- Speed up `check_repo`/`check_run` in sequential mode (`MAKE_PARALLEL=no`) by running the test execution of the suppliers concurrently (`cawk_chk_exec_run` + `wait` in `cawk_check_body`): `check_repo` 15 s to 5.4 s, identical reports
- Replace the 12 duplicated bodies of `check_repo`/`check_run` (repo|run|audit x suppliers x sequential|parallel) by one `cawk_check_body` canned recipe in `support/Makefile.support.check.scope.mk` and removing the duplicated recipes, the `Makefile` shrinking from 867 to 266 lines
- Add `CENSOR_LEVEL=internal|external` option (default `internal`) to the `censor_*` targets, checked by `check_supplier` and passed to `censor.gawk`
- Add `STANDARD_ONLY=yes` option (mirror of `PSIRT_ONLY`) running only the standard tests, rejected with `PSIRT_ONLY=yes` by `check_supplier`
- Add `support/Makefile.support.censor.mk` with `censor_repo`, `censor_run` (`audit=` optional) and `censor_run_audit`, with no Makefile variable, writing `confs/<context>/confs.<supplier>.censored`
- Add the final `cawk <target> done ----` message to every target of `support/Makefile.support.git.mk`
- Fix the `FORCE=yes` guard: `cawk error:` message and non-zero exit for `clean_orig`/`clean_force` and the `git*` targets (`gitnewbranch`, `gitinstallcicd`, `gitcommit`, `gitpush`, `gitpushbranch`, `gitpr`, `gitprmerge`, `gitmasterupdate`, `gitpushtag`)
- Add `clean_censor_repo`, `clean_censor_run` (`audit=` optional) and `clean_censor_run_audit` to `support/Makefile.support.clean.mk` (`supplier=` optional)
- Add `clean_censor_repo`, `clean_censor_run` and `clean_censor_run_audit` to `clean_force`
- Make `censor_*` depend on `database/censor/censor_regex`, built from `censor_regex.m4` by the `%: %.m4` rule
- Make `censor_*` fail on `supplier=` with no `confs.<supplier>` directory (without `supplier=` the missing ones are skipped)
- Exclude the `confs.<supplier>.censored` directories from the `catalog_*`/`catalog_exceptions_*` supplier lists and from `gitcheck`
- Add `censor_file in= out=` (one file censored into one file), `censor_stdout in=` (censored to the standard output) and `censor_check in=` (exit 1 while a text the regexes would censor is still there) to `support/Makefile.support.censor.mk`
- Add `censor_logs_repo`/`censor_logs_run` (`audit=` optional)/`censor_logs_run_audit` and `censor_report_repo`/`censor_report_run` (`audit=` optional)/`censor_report_run_audit` to `support/Makefile.support.censor.mk`, writing `logs/<context>.censored` and `reports/<context>.censored`
- Add `clean_censor_logs_*` and `clean_censor_report_*` to `support/Makefile.support.clean.mk` and to `clean_force`
- Make `delete_audit` remove the `logs/run_<audit>.censored` and `reports/run_<audit>.censored` directories
- Add `SECRETSCAN=yes`: censors the final `assessment.*.csv` into `assessment.*.censored.csv` (error_line column only), removes the originals and builds the timeline/json/html reports from them; `view_*` and the email export follow
- Add the `SECRETSCAN` value check to `check_supplier` and its status line to the `check_repo`/`check_run` output
- Add a `check_repo SECRETSCAN=yes` pass to `check` (and `check_parallel`) that verifies no uncensored csv report is left

### Database

- Add the `local` collector (`database/collectors/local.collector.sh`, `source_path=LOCAL_DIR`): copies with `cp -p` the files of a directory of the cawk machine into `confs/collect_<audit>`
- Extend `censor_regex.m4`: MONITORING (`rocommunity`/`rwcommunity`, `createUser`, trap `community`), SECRET (`authpwd`/`privpwd`/`auth-pass`/`priv-pass`, `psk`, `wpa-psk`, `wpa-passphrase`, `set-key`, `bind-password`/`bind-pw`, HSRP/GLBP `authentication`) and URL credentials `scheme://user:pass@`

- Fix `psirt_os_inventory_scope.txt`: `conf_psirt_cisco-ios_vuln`/`_fixed` declare `15.1`/`17.1` (were `1.0`/`2.0`): `vuln` matches the cisco-ios `OS[1]` pattern, `fixed` matches none
- Fix `catalog_build_db.gawk.template` lowercasing the test name in `db_info.txt`: the 17 psirt tests (`CVE…`) keep their case, identical in the csv, json, txt and html reports and found by the html/report catalog lookups
- Add to `censor_regex.m4` the `password-hash`/`expert-password-hash`/`grub2-password-hash`/`phash` keywords and two generic hash-format rules (`$1$ $5$ $6$ $8$ $9$ $y$ $2a$`, `grub.pbkdf2.sha512`), and restrict the `community` rule to indented lines (BGP communities kept)
- Add 8 cases (5 censor, 3 keep) to `validate/censor/cases.tsv`
- Add `database/db_collect.txt` (audit collector args) and `database/collectors/` (`scp` and `rsync` collectors fetching the confs from one central unix/linux system with `host=`/`user=`/`remote_path=`/`key=`/`options=`, `collector_common.sh`; the copy is automatic), external optional scripts filling `confs/collect_<audit>`
- Add `COLLECTORS_PATH` to `support/Makefile.support.mk` and `database/include/scripts_config.sh`
- Add a fourth optional argument (the replacement word, `CENSORED` by default) to the `cawk_censor.m4` macros, `censor_regex` lines become `<level><tab><word><tab><regex>`
- Generate `censor_regex` as gawk code (regex constants, `censor_apply()`) included by `censor.gawk` instead of loading dynamic regexes, `censor_repo` 12 s to 1.9 s on the demo confs
- Remove `CENSOR_REGEX_FILE` from `censor.gawk`, add `%SED_CENSOR_REGEX_PATH%` to `tests.sed`
- Add `database/censor/censor_regex.m4` (censor macros calls) built into `censor_regex` (one regex per line)
- Merge the syntaxes of every supplier into one regex per section of `censor_regex.m4` (ADMIN, AUTHENTICATION, CRYPTO, SECRET, MONITORING), starting from the existing regexes, `service password-encryption` still censored
- Add the sections CERTIFICATE (`internal`), IDENTITY and TOPOLOGY (`external`) to `censor_regex.m4`

### Build

- Fix `common/report_html.skeleton.html` to check the info risk and the PSIRT not affected / skipped status by default
- Fix `common/report_html.skeleton.html` summary by risk: pass first, PSIRT split in PSIRT vulnerable and PSIRT not affected, drop the skipped wording
- Fix `number_of_psirt` in `common/report.gawk.template` to count only high risk (vulnerable) PSIRT results, as the html report does
- Add `number_of_psirt_clear` in `common/report.gawk.template` for the PSIRT results not affected or skipped
- Fix `number_of_nist_warning` in `common/report.gawk.template` to stop counting PSIRT results
- Add `banner` block exclusion to `badformat_cawk_conf.gawk.template`
- Fix `badformat_cawk_conf.gawk.template`: ignore indented `!` comment lines
- Fix `gen_cawk_makefile.gawk` and `sync_cawk_conf.gawk` usage errors: `cawk error` message then `exit 1` (was `exit 0`)
- Fix `psirt_block_line()` of `m4/cawk_psirt.m4`: undeclared block stops `m4` (`m4exit(1)`)
- Fix `sync_cawk_conf.gawk`: quote the `cat`, `find`, `mkdir` and `ln -s` arguments with `shell_quote()`, close the `cat` pipe with `close(cmd)`
- Fix `deadbeef_cawk_conf.script.sh`: remove the duplicated `days` in the old configuration message
- Fix `rm_semicolon()` comment in `common.gawk.template`: semicolons are removed, not replaced
- Fix `report_html.gawk.template` and `report_html.skeleton.html`: only `psirt` at `high` risk is a vulnerability, `info`/`low`/`medium` are "not affected / skipped"
- Fix `common/report_sumjson.gawk.template`: the `exceptions purposes` section is now an array of `{audit, supplier, id, purpose, rules}` objects (was the template comment lines parsed as key/value pairs)
- Fix `find` on `confs`, `tests`, `reports`, `database` in `Makefile.support.backup.mk`, `Makefile.support.check.mk`, `Makefile.support.clean.mk`, `Makefile.support.tests.mk`: `-H`, the persistent volume of the container links these directories (`backup_run_audit` archived no file)
- Fix `docker/Dockerfile`: add the packages `sed`, `rsync`, `openssh-client`, `zip`, `mutt`, add `COPY roles` and `COPY Makefile.cawk.version`
- Fix `docker/Dockerfile`: add `COPY validate`, drop the 17 redundant per-file `COPY support/Makefile.support.*.mk` lines
- Add `common/censor.gawk.template`: applies the regexes of `censor_regex` (group 1 kept, the rest of the match censored), with no password/monitoring block
- Add `CENSOR_OUT_FILE` (the mode censor writes one file into one file) and `CENSOR_MODE=check` (nothing written, exit 1 when a line would still be censored) to `common/censor.gawk.template`
- Add `m4/cawk_censor.m4` with the `censor_after`, `censor_match`, `censor_line` and `censor_ignore` macros, and the optional 2nd argument `lowercaseuppercase` (case-insensitive regex)

### Docs

- Rename `memory/CAWK_CODE_RULES.md` to `docs/CAWK_CODE_RULES.md`, references updated in `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `docs/CAWK_OPTIONS.md`, `support/Makefile.support.mk`
- Rename `logo/` to `docs/logo/`, references updated in the `LICENSE`, `README.md`, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `AUTHORS.md`, `ChangeLog.md` headers, `docs/CAWK_OPTIONS.md`, `support/Makefile.support.mk` (`LOGO_HTML`)
- Add `COPY docs` to `docker/Dockerfile` (the logo of the html report and the docs imported by `CLAUDE.md` were missing from the image)
- Add `docs/CAWK_SED_PLACEHOLDERS.md`, `docs/CAWK_OPTIONS.md`, `docs/CAWK_DATABASE_FORMAT.md`, split from `CLAUDE.md` which now imports `memory/CAWK_CODE_RULES.md`
- Add `docs/audits/` for the Makefile and package audit reports
- Add `AGENTS.md` at the repository root pointing to `CLAUDE.md` (technical reference) and `memory/CAWK_CODE_RULES.md` (development rules)
- Fix help: add FORCE=yes, the git*, roles_*, nist_coverage_*, catalog_build_*, exceptions_build_*, exceptions_run_audit, check_*, clean_tmp, tests_target_*, database_target_sh targets; remove the duplicated exceptions_build and the wrong `view_` prefix, `view_run_error` directory and `cakw` typo
- Fix README: backup file names, database script and scope paths, `.all.deadbeef.csv`, timeline reports list, postaudit `update`, catalog_build and exceptions_build_repo descriptions, DEADBEEF typo, email database quotes, run_audit step numbering
- Add README: MAKE_FILES_PER_TARGET_PSIRT, MAKE_FILES_PER_TARGET_MAX, CATALOG_BUILD, TMP_ASSESSMENT_FILES, ARCHIVE_OLDER_DAYS, HTML default, mutt and zip prerequisites
- Add CLAUDE.md: FORCE=yes requirement
- Document the psirt risk levels in `README.md` (cawk psirt tests, assessment format) and `CLAUDE.md` (PSIRT & Include Tests)
- Add the `cawk workflow` chapter to `README.md` (collect, sync, align, audit, read, share, keep) with a drawing per step
- Add the final HTML report (`HTML=yes`, `assessment.all.summary.html`) to the README workflow: big picture, new step 8 and daily run
- Document the optional collectors (`database/collectors`, `db_collect.txt`, `COLLECT`, `COLLECTORS_PATH`, `confs/collect_<audit>`) in `README.md` and `CLAUDE.md`
- Document the `censor_*`/`clean_censor_*` targets and the `censor_regex.m4` macros in `CLAUDE.md`, `README.md` and the `gmake` help
- Add an optional third argument `internal` (default) or `external` to every censor macro of `m4/cawk_censor.m4`, generated as `<level><tab><regex>` and filtered by `common/censor.gawk.template` (`external` applies internal and external regexes, `internal` only the internal ones)
- Describe cawk as a network configuration compliance checker and censor in the `gmake` help logo, `README.md`, `CLAUDE.md` and `SECURITY.md`
- State in `CLAUDE.md`, `README.md`, the `gmake` help and `Makefile.support.censor.mk` that `database/censor/censor_regex.m4` is the only file to edit for the censor module, and document `censor_line` and the `lowercaseuppercase` argument in `CLAUDE.md`
- Document the new censor usages (`censor_file`, `censor_stdout`, `censor_check`, `censor_logs_*`, `censor_report_*`) in `CLAUDE.md`, `README.md` and the `gmake` help

### CI/CD

- Bump `softprops/action-gh-release` to `v3` (Node 24) and pin the `release.yml` runner to `ubuntu-24.04` in `.github/workflows/` and `cicd/`

---

## [v4.0.0] - october 2026

### Makefile

- Add `gitcheck_orthogonality` (called by `gitcheck`, replaces the weak metadata check): per-tag metadata, `@risk_level` values, `%SED_*%` placeholders, Make/shell path variables, `SUPPLIER_SCOPE` vs repo directories, psirt twins
- Add `gitcheck` section failing on `run_*` directories in `logs`/`reports`/`tests`/`exceptions`/`confs` absent from `list_audit`
- Trace previously silent `sync_run`'s `sync_cawk_conf.gawk` call and final-report generation (`report.gawk` family) to `.err` logs
- `check_repo`/`check_run` call `clean_logs_repo`/`clean_logs_run FORCE=yes` at the start of each run
- Harden `exceptions_run`/`exceptions_repo` m4 compilation against silent EMFILE/ENFILE failures (atomic temp-file + exit-status checks)
- Fix `check` self-test leaking non-numeric text (dates, hashes) into `checkdiff.new`, causing spurious daily `NOK`
- Add end-of-run error summary (`cawk_check_errors_scan`) to `check_repo`/`check_run`
- Add `exceptions_run_audit` target (all named audits in one call)
- **Breaking change:** rename `PSIRT` option to `PSIRT_ONLY`; old name now rejected with `exit 1`
- Show `(MAKE_PARALLEL=... PSIRT_ONLY=...)` in the `cawk compute ...` messages
- Show the controlling option in temp-file/JSON report messages
- Report deadbeef/badformat/crlf filter status and counts via new `cawk_filter_idx` macro
- Add crlf detection (`crlf_cawk_conf.gawk.template`, `CRLF` option, forced `yes` by default)
- Add badformat detection (`badformat_cawk_conf.gawk.template`, `BADFORMAT` option)
- Add `database_view_sync`/`database_view_email`/`database_view_postaudit` targets
- Add ASCII banner to `gmake help`
- Fix broken symlinks in `sync_cawk_conf.gawk.template` for relative `dir=` paths (missing one `../`)
- Make `check_deprecated_repo`/`check_deprecated_run` non-blocking; add success message
- Add `FORCE=yes` guard to `clean_logs`/`clean_logs_repo`/`clean_logs_run`
- Add obsolete-`.gawk` detection to `gmake clean`
- Add deprecated-function source-quality gate (`check_deprecated_repo`/`run`, wired before `tests_repo`/`tests_run`)
- Fix `sync_run` running `database_sync.script` unconditionally, even without `audit=`
- Fix literal `\n` in `sync_teststoconfs_run`/`sync_exceptionstoconfs_run` echoes
- Add `gmake check` coverage for `sync_run`, `database_email_*`, `database_postaudit_*`
- Fix `exceptions_repo`/`exceptions_run` silently swallowing `m4` failures (ARG_MAX-unsafe `$(foreach)` replaced by a shell loop + `.err` check)
- Add `RUN_DIRS_FIND` and switch 11 `for x in $(RUN_DIRS)` call sites to a shell-level loop (ARG_MAX safety at audit-count scale)
- Batch `check_deprecated_*`/deadbeef scan/`clean`'s `touch` with `find -exec ... {} +`; drop 4 processes per compiled test in the `%.gawk` pattern rules; disable implicit rules (`MAKEFLAGS += -r`)
- Fix `view_run audit=X`/`migrate` error branches masking failure via a standalone `exit 0`
- Fix `restore_run` (no `audit=`) creating a stray `confs/run_` directory
- Fix named-audit deadbeef skip condition missing PSIRT-only suppliers (`cawk_deadbeef_scan_guarded`)
- Fix `check_run audit=X supplier=Y` running the deadbeef scan/exception filtering on a missing supplier directory
- Fix `sync_run`'s `cd ... && script && cd ../..` leaving the shell in the wrong directory on failure (now a subshell)
- Fix `nist_coverage_repo`/`run` counting controls across every context instead of the current one (unanchored field 1/2 matches)
- Fix `.PHONY` typo `clean_roig_info` → `clean_orig_info`
- Fix `gitcheck` unquoted `find` pattern and wrong `*.script` listing
- Fix `view_repo_error`/`view_run_error` `supplier=` filter (empty-alternation regex matched everything)
- Fix `check_repo`'s audit-misuse guard masking failure via `exit 0` → `exit 1`
- Fix literal `\n` in `database_view`/`check_repo` echoes
- Add `TODAY` computed once per invocation, replacing repeated `$(shell date ...)` calls
- Simplify `postaudit_run_audit`/`sync_run_audit`/`view_*_error`/`database_view`: drop unnecessary `cat` subprocesses
- Fix `check_run`'s audit-existence guard evaluated at parse time instead of runtime (chained `create_audit check_run` saw stale state)
- Fix `create_audit`/`delete_audit` error branches masking failure via `exit 0` → `exit 1`
- Fix `database_email_add`/`update` missing audit-existence guard (ghost `db_email.txt` entries)
- Reorder `check_repo`/`check_run` prerequisites: `check_supplier` now runs first
- Add `MAKE_FILES_PER_TARGET_MAX` (2000) safety ceiling against `ARG_MAX` in parallel mode
- Capture stderr to `logs/*.err` (was `2>/dev/null || true`, or unconditional success for `restore_run`) across test execution, deadbeef/badformat/crlf scans, backup/restore/archive, email, sync/postaudit, catalog precompute, and PSIRT parallel generation; harmonize failure messages on `cawk error:`
- Fix `ARG_MAX` risk in sequential test execution: replace Make-level `$(foreach)` expansion with a shell-level loop
- Scope all `*.err` logs under `logs/repo`, `logs/run`, or `logs/run_<audit>` to mirror `reports/`; add `clean_logs_repo`/`clean_logs_run`/`clean_logs_run_audit` targets

### Tests

- Add interface name to the `error` line of `int_ipv6redirects_notset` (`cisco-ios`, `cisco-xe`, `cisco-xr`)
- Add interface name to the `error` line of `int_allowall_notset` and `int_allowforbidproto_notset` (`cisco-viptela`)
- Speed up `cawk_hypercube_rules_assessment` in `common_hypercube-lib.gawk.template` (flat cube arrays, hoisted rule fields, memoized ip/net conversion), ~6x faster on large `acl_configconsistency_set` filters with identical reports
- Align all 420 `@nist800-53_ref` tags with `database/db_nist800-53.txt` (id, category and description now identical; 3 Junos 4-field refs and 8 divergent descriptions fixed)
- Harmonize the NIST control per check across suppliers (`global_duplicaterule_notset`, `global_rulelog_set`, `global_http_notset`, `ntp_ip_set`, `snmp_v3user_set`, `*lldp*_notset`, `int_icmpunreachable_notset`, `global_defaultpolicy_set`); `tcl_script_notset` now maps to CM-7
- Remove `;` from 23 `@description`/`@actions` tags (it is the `db_info.txt` field separator)
- Fix message typos in `syslogd_enable_set.fortinet-fortios`, `line_aclin_set.cisco-xr` and `global_ipioclist_set` (checkpoint/iptables/packetfilter)
- Fix `global_defaultpolicy_set.packetfilter-fwcli` reporting "policy option limit" for every option
- Fix `protocols_lldpcdp_notset.juniper-junos` message prefixed by an unset variable and pass reported with line 1
- Fix `%SED_OLD_CRYPTO%` missing an older algorithm at end of line (`md5`, `sha1`, `3des-cbc`) and `tlsv1.0`/`tlsv1.1` (11 `*oldercryptoalg_notset` tests)
- Fix `%SED_AUTHUSER_CISCO%`/`_CEDGE`/`_HUAWEI`/`_JUNI`/`_VIPTELA%` accepting any name starting with `admin` (`administrator2`, `adminhack`); anchor the Viptela `aaa_user_notset` user match
- Fix `global_passwordpolicy_set.checkpoint-fwcli` passing when only some of min-length/complexity/history are configured; report each missing option separately
- Extend `check_test.gawk` to reject tests without `ENDFILE` or without any `print_err()` call, and read every `print_err()` (spaces, multi-line, several per line, non-literal test name)
- Extend `check_test.gawk` to compare `@test_name`, `@supplier` and the filename supplier suffix with the file and its `tests.<supplier>` directory
- Fix `check_test.gawk` flagging `debug` inside `print_err()` messages; remove its dead code (`count_func_args`, unused variable tracking) and `FIX n` history comments
- Fix `snmp_v1v2rw_notset.juniper-junos` never matching Junos `authorization read-write`
- Fix `snmp_v3host_set.cisco-viptela` counting a `host` outside the `trap` block (m4 `trap` block had no end hook)
- Fix block state leaking between config files (reset in `BEGINFILE`) in 19 tests: fortinet-fortios `fw_*`, paloalto-panos `aaa_authprofile`/`login_banner`/`snmp_*`, juniper-junos `aaa_user`/`ntp_ip`/`snmp_v1v2rw`/`snmp_*viewdefref`/`acl_configconsistency`, cisco-viptela `aaa_authorder`/`aaa_user`/`snmp_v1v2rw`
- Fix silent results: `fw_lastrule_set.fortinet-fortios` (error without policy), `protocols_bgpgroupauth_set`/`protocols_bgpneighborauth_set` (juniper-junos), `global_sshratelimit_set` (iptables-fwcli, packetfilter-fwcli) and `global_icmpratelimit_set.iptables-fwcli` (pass when nothing to check)
- Fix `fw_allall_notset.fortinet-fortios` missing all/all/ALL accept policies (verdict now taken at `next`, since FortiOS writes `set action` before `set service`)
- Fix `linevty_aclin_set`/`linevty_aclout_set` (cisco-ios, `linevty_aclin_set.cisco-sdnios`) accepting an access-class of the opposite direction
- Fix `crypto_isakmpkeyenc_set` (cisco-ios/xe/xr/cedge) accepting cleartext `key 0` and digit-only keys (only `key 6` is encrypted)
- Fix `ntp_ip_set` (cisco-ios/xe/cedge) missing `ntp server vrf <name> <ip>`
- Fix `snmp_v1v2rw_notset` (cisco-ios/xe/xr/cedge/sdnios) matching `RW` inside community names
- Fix `aaa_classdefref_set.juniper-junos` reporting Junos predefined classes (`super-user`, `operator`, `read-only`) as undefined
- Fix `int_proxyarp_notset.juniper-junos` (`proxy-arp` at unit level) and `int_directedbroadcast_notset.juniper-junos` (`targeted-broadcast`) never matching Junos syntax
- Fix `services_ssh_set.juniper-junos` broken `%SED_BK_JUNI%` placeholder
- Fix `int_arpproxy`/`int_directbroadcast`/`int_ipredirects`/`int_lldp` (huawei-vrp) never closing interface blocks (`#` terminator)
- Fix `lldp_system_notset.nokia-sros` reporting active LLDP as `pass`
- Fix `aaa_server_set`/`login_logenable_set` (ekinops-oneos) reporting a missing configuration as `pass`
- Fix `global_ntp_set` (ntp `enabled off` seen as active), `global_passwordpolicy_set` (spurious "complexity unknown") and `global_ruleinfo_set` (`warning` instead of `pass`) in checkpoint-fwcli
- Fix `global_statefulrules_set.iptables-fwcli` rejecting `RELATED,ESTABLISHED` order and `global_sshratelimit_set.iptables-fwcli` silent on rate-limited ssh accept
- Fix `global_ipioclist_set` (iptables-fwcli, packetfilter-fwcli) analysing only the last line of multi-line rules
- Fix `global_basicrulecheck_set` (valid `on`/`inet6`/`proto`/`from`/`to`/`return-*` flagged), `global_ruleinfo_set` (`pass in all` missed) and `global_tabledefref_set` (pass emitted after error) in packetfilter-fwcli
- Fix `system_networkstackipcompliant_set.6wind-linux` unbalanced block-exit regex
- Fix `aaa_config_set.cisco-xe`/`cisco-xr` never reporting a missing `(tacacs|radius) server` (`pass_serv` typo for `pass_ser`)
- Fix `linevty_sshinput_set.cisco-ios`/`linevty_sshoutput_set.cisco-ios` being metadata-only (no logic), ported from cisco-xe
- Fix infinite loops in `routing_communitydefref_set.juniper-junos` (`default` in policy list), `global_defaultpolicy_set.packetfilter-fwcli` and `global_rulevarinfo_set.packetfilter-fwcli` (unterminated `{ ... }` macro)
- Rename `aaa_config_set`/`aaa_user_notset`/`ntp_enablestatus_set` from `.fortinet` to `.fortinet-fortios` (supplier naming convention)
- Fix `global_chaindefref_set.iptables-fwcli` missing `iptables -t <table> -N` chain definitions and `-g` (goto) references
- Fix `fw_lastrule_set`/`fw_anyany_notset`/`fw_forbidproto_notset` (paloalto-panos) leaking block state from one config file to the next
- Fix `global_snmpcustforbidcommunity_notset.6wind-linux` rejecting a destination that ends at `port 162`
- Fix `ntp_ip_set.nokia-sros` NUL character in server regex and `routing_communitydefref_set.juniper-junos` unescaped `+` in community regex
- Remove unused variables in `global_logging_set.cisco-viptela`, `global_trusthost_set`/`global_tlsminversion_set` (fortinet-fortios), `global_adminlockout_set.checkpoint-fwcli`, `global_snmpcustforbidcommunity_notset.6wind-linux`, `global_rulevarinfo_set.packetfilter-fwcli`, `acl_configconsistency_set.cisco-xr`
- Fix `global_snmpcustforbidcommunity_notset.6wind-linux` message typo and add missing `@authors` to `routing_communitydefref_set`/`routing_ribgroupdefref_set` (juniper-junos)
- Fix `acl_configconsistency_set` destination-port parsing (cisco-ios/xe/cedge/xr): decode `range`/`gt`/`lt`/`neq`, not just `eq`
- Fix `acl_configconsistency_set` ICMP type/code false positives across 6 suppliers via new `cawk_icmp_overlap()`
- Fix `acl_configconsistency_set.packetfilter-fwcli` ignoring pf.conf line continuations
- Fix `acl_configconsistency_set.huawei-vrp` rule parsing (`ocal_current` typo, literal `eq` port, protocol regex swallowing `source`)
- Fix `acl_configconsistency_set` (6 suppliers) silently skipping the last ACL of a file; fix cisco-xr ACL name field
- Add `acl_configconsistency_set.juniper-junos` (10th supplier) with a 26-scenario fixture
- Add `acl_configconsistency_set` to checkpoint-fwcli and iptables-fwcli (9th/8th suppliers) with fixtures (22/14 scenarios)
- Add `conf_acl_consistency` non-regression fixtures for the 7 remaining `acl_configconsistency_set` suppliers
- Fix `report_timeline.gawk.template` unclosed `date` pipe
- Fix `test_generic_psirt.gawk.template` leaking a `grep` pipe on the not-found path
- Add `lineaux_loginauth_set`/`linevty_loginauth_set` (cisco-ios/xe/cedge), `aaa_configlogin_set.cisco-xr`
- Fix `linevty_loginauth_set`/`lineaux_loginauth_set`: skip `transport input none`
- Add `int_ipv6redirects_notset` (cisco-ios/xe/xr)
- Add `int_cdpenable_notset`/`int_directedbroadcast_notset`/`int_ipredirects_notset`/`int_ipunreachables_notset`/`int_proxyarp_notset` (cisco-xr)
- Add `crypto_isakmpkeyenc_set` (cisco-ios/xe/xr/cedge): require type-6 encrypted ISAKMP pre-shared keys
- Fix `snmp_v1v2_notset`/`snmp_v1v2rw_notset`/`snmp_v1v2forbidcommunity_notset`: report every matching community line, not just the first
- Fix `int_ipv6redirects_notset`: skip Loopback/shutdown interfaces, report the offending address
- Fix `int_*_notset` interface tests (cisco-ios/xe/cedge, huawei-vrp): skip `shutdown` interfaces
- Fix juniper-junos `int_directedbroadcast_notset`/`int_proxyarp_notset`/`int_redirects_notset`/`int_unreachables_notset`: exclude `inactive:` interfaces at the begin hook
- Add `conf_acl_consistency_big` (~2000 lines, known error count) to the 9 `acl_configconsistency_set` suppliers to measure test run time at scale

### Database

- Add `database/include/scripts_config.sh`, a POSIX-shell mirror of the Make path variables
- Add `db_sync.txt` field 7 `regexinventoryexclude` (scope-file exclusion regex)
- Rename `db_sync.txt` field 3 `device_regex` → `inventory_regex`; now filters scope-file lines, only when `scope_file` is set
- Rename `database_sync_add`/`update` param `regex=` → `regexinventory=`

### Supplier

- Add supplier `cisco-sdnios`: register in `SUPPLIER_SCOPE`, sample confs, `linevty_aclin_set` test, exceptions file
- Add 5 ported cisco-sdnios tests (`acl_defref_set`, SNMP v1v2 forbid/RW community, `aaa_user_notset`, `aaa_config_set`)
- Add cisco-sdnios detection to `sync_cawk_conf.gawk` (`system-user`/`! Version` + `line vty` markers)
- Fix missing `dst_prefix_cisco_sdnios` mapping: sync could detect cisco-sdnios but never routed configs to it

### Docs

- Add CLAUDE.md golden rule for `acl_configconsistency_set.<supplier>`: call `cawk_add_hypercube_rules()` directly, never through a per-supplier wrapper
- Add CLAUDE.md section on Make ↔ shell path-variable consistency

### CI/CD

- Upgrade `actions/upload-artifact` v5→v7 for Node.js 24 compatibility

---

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
