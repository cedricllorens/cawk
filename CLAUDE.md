# CLAUDE.md

cawk is a network configuration compliance checker and network configuration censor.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. It holds the **technical reference** (architecture, commands, formats). The **development rules** (how to work safely and consistently on cawk, git workflow, code style, testing and documentation practices) are in [CAWK_CODE_RULES.md](docs/CAWK_CODE_RULES.md).

@docs/CAWK_CODE_RULES.md

**Reference split into [docs/](docs/), read on demand:** [placeholders `%SED_*`](docs/CAWK_SED_PLACEHOLDERS.md), [global options](docs/CAWK_OPTIONS.md), [database formats and censor_regex](docs/CAWK_DATABASE_FORMAT.md).

## Core Tools

cawk relies exclusively on three tools — no other languages or dependencies:

- `gawk` (GNU AWK) — test execution engine
- `gmake` (GNU Make) — build system and task runner
- `m4` (GNU M4) — macro expansion for test templates

All commands use `gmake`, not `make`.

The optional config collectors (`database/collectors/*.collector.sh`, see [db_collect.txt](#db_collecttxt)) are the only exception: they are external scripts that may use `scp`, `rsync` or `cp` (local), they only fill `confs/collect_<audit>`, and nothing in cawk requires them (never call them from `check_*`, `check` or `check_parallel`).

## Common Commands

```bash
# List the help sections, print one section (info main assessment sync collect tests exceptions checks view email postaudit backup database catalog roles git censor vars), print all of them
gmake
gmake help
gmake help sync
gmake help all

# Search a word in every help line (a target, an option), where an audit stands, tab completion in bash
gmake help topic=censor_file
gmake status audit=client1
gmake status
source support/cawk-completion.bash
# everywhere, in ~/.bashrc: export CAWK_HOME=/home/cedric/Documents/cawk ; source "$CAWK_HOME/support/cawk-completion.bash"

# Show cawk version
gmake version

# Run integrity check (before first use after install)
gmake check

# Check the format of every cawk database (also run by check), one explicit error per bad line
gmake check_database

# Same as check, recording each phase (counter, counted content, command, exit status) in checkdiff/track/trace and explaining a NOK (phase, command, exit status, changed lines, stopped run, stale reference)
gmake check_track
gmake check_track_explain
gmake check_track_update
gmake clean_track FORCE=yes

# Run repo assessment (demo configs + tests)
gmake clean check_repo view_repo

# Run assessment for a named audit
gmake clean check_run view_run audit=client1

# Run assessment for a specific supplier only
gmake check_run view_run audit=client1 supplier=cisco-ios

# Build compiled .gawk files from templates (no assessment)
gmake tests_repo
gmake tests_run audit=client1

# Create / delete a named audit
gmake create_audit audit=client1
gmake delete_audit audit=client1 FORCE=yes

# List all named audits
gmake list_audit

# Optional config collectors (confs/collect_<audit>, linked by the sync into confs/run_<audit>)
gmake database_collect_add audit=client1 collector=rsync args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519 sync=yes
gmake collect_run audit=client1
gmake collect_run_audit
gmake sync_run audit=client1 COLLECT=yes
gmake check_collect

# Evolution of a named audit: check_run audit= writes one file per date database/data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt (directory created by create_audit, removed by delete_audit, DATA_SET_KEEP dates kept, default 180) and the html report (HTML=yes) alone tracks the evolution of the audit over time, `assessment.all.summary.txt` and `.json` do not hold it (section "Evolution of the audit": compliance score, Pass / Errors, High/Medium/Low errors, Errors/Devices per date; not affected by the filters)
gmake check_run audit=client1
gmake check_run audit=client1 DATA_SET=no

# After a cawk update: run your own script database/scripts/update_custom.script.sh (empty by default, edited by the user, global, FORCE=yes required, errors in logs/update_custom.err)
gmake update_custom_run FORCE=yes

# Clean generated files
gmake clean

# FORCE=yes is required by clean_logs*, clean_orig, clean_force, delete_audit and every git* target (gitcheck* excepted)
gmake clean_orig FORCE=yes

# Clean persisted execution logs (not touched by gmake clean)
gmake clean_logs_repo
gmake clean_logs_run
gmake clean_logs_run audit=client1
gmake clean_logs_run_audit

# Censor the configurations (confs.<supplier> -> confs.<supplier>.censored)
gmake censor_repo
gmake censor_run
gmake censor_run audit=client1
gmake censor_run_audit
gmake censor_repo supplier=cisco-ios

# Censor one file (in= out=), to the standard output (in=), or check that no secret is left (in=)
gmake censor_file in=confs/run/confs.cisco-ios/r1.cfg out=/tmp/r1.cfg.censored
gmake censor_stdout in=confs/run/confs.cisco-ios/r1.cfg
gmake censor_check in=confs/run/confs.cisco-ios.censored

# Censor the logs and the reports of an assessment (logs/<context> -> logs/<context>.censored, same for reports)
gmake censor_logs_repo
gmake censor_logs_run
gmake censor_logs_run audit=client1
gmake censor_logs_run_audit
gmake censor_report_repo
gmake censor_report_run
gmake censor_report_run audit=client1
gmake censor_report_run_audit

# Remove the censored configurations (supplier=SUPPLIER restricts to one supplier)
gmake clean_censor_repo
gmake clean_censor_run
gmake clean_censor_run audit=client1
gmake clean_censor_run_audit

# Remove the censored logs/reports (same audit= convention)
gmake clean_censor_logs_repo
gmake clean_censor_logs_run
gmake clean_censor_logs_run audit=client1
gmake clean_censor_logs_run_audit
gmake clean_censor_report_repo
gmake clean_censor_report_run
gmake clean_censor_report_run audit=client1
gmake clean_censor_report_run_audit
```

## Test Template Pipeline

Tests are **never written as `.gawk` directly**. They are authored as one of four source formats and compiled at build time:

| Source format | Compiled via | Use case |
|---|---|---|
| `*.gawk.template` | `sed` (support/tests.sed) | Standard tests |
| `*.gawk.m4` | `m4` then `sed` | Tests needing M4 block-parse macros |
| `*.gawk.include` | `sed` (PSIRT mode) | PSIRT vulnerability tests |
| `*.gawk.include.m4` | `m4` (`m4/cawk_psirt.m4`) then `sed` (PSIRT mode) | PSIRT tests written with the psirt macros |

The build rule (defined in the Makefile support files, see below) converts these to `*.gawk` files. The sed rules in `support/tests.sed` substitute vendor-specific placeholders (e.g., `%SED_GAWK_PATH%`, `%SED_AUTHUSER_CISCO%`) with system/vendor-specific values.

Placeholders `%SED_*` (defined in `support/tests.sed`): see [docs/CAWK_SED_PLACEHOLDERS.md](docs/CAWK_SED_PLACEHOLDERS.md).

## Directory Layout

`database/` is the **user side** (his data and the rules or scripts he edits: saved by `backup_run*`, restored by `restore_run*`, never rewritten by a new cawk version); `common/` is the **cawk system side** (code and reference files shipped with each version: never saved nor restored, replaced by an update, not to be edited). See the rule "User data versus cawk system code" in [CAWK_CODE_RULES.md](docs/CAWK_CODE_RULES.md).

```
tests/
  repo/             # Full test collection (source of truth)
    tests.<supplier>/         # e.g. tests.cisco-ios/
    tests.<supplier>.psirt/   # PSIRT-specific tests
  run/              # Default copy of repo (editable)
  run_<audit>/      # Per-named-audit copy

confs/
  repo/             # Demo/reference configurations
  run/              # Default run configurations
  run_<audit>/      # Per-named-audit configurations
  collect_<audit>/  # Raw configs filled by a collector (secrets: not backed up, not cleaned, removed by delete_audit)
  <context>/confs.<supplier>.censored/   # Generated by censor_* (never read by assessments)

exceptions/
  repo/             # Exception rules (applied during reporting)
  run/, run_<audit>/

validate/               # every run.sh below is run by `gmake check` (the `check_validate` phase)
  badformat/          # fixtures of the badformat scan (first-level indentation violations): conf_ok, conf_ko (see README); no run.sh
  crlf/               # fixture of the crlf scan (windows CRLF endings, kept by `.gitattributes`): conf_crlf (see README); no run.sh
  recap/run.sh        # non-regression of the final recap of check_run (VERBOSE=no|yes, totals against assessment.all.csv, tests x confs, STANDARD_ONLY), in a temporary audit
  sync-scope/run.sh   # non-regression of the default sync scope (database/sync_scopes/<audit>_inventory_sync_scope.txt created empty by create_audit, empty/missing/filled/none scope), in a temporary audit
  completion/run.sh   # non-regression of support/cawk-completion.bash (targets, audit=, supplier=, options, fallback outside a cawk root), in a temporary audit; skipped when bash is missing
  messages/run.sh     # non-regression of the error messages: `cawk error: <message> ----` format, early audit= validation (`check_audit`), help sections, unknown target message
  integrity/run.sh    # non-regression of check_integrity (obsolete files of DEPRECATED_FILES and censor rules: `cawk error:` shown, check_repo and check_run go on, no exit 1), no file created or removed
  psirt/run.sh        # non-regression of the psirt engine (common/test_generic_psirt.gawk.template): one directory per case (rule.include, inventory.txt, c_*/x_* confs, expected.txt)
  censor/run.sh       # non-regression of censor_regex.m4: validate/censor/cases.tsv, secrets censored and benign lines intact at both levels
  collect/run.sh      # non-regression of the collectors (database/collectors/) and of their link with the sync (`gmake check_collect`, no network: scp/rsync shimmed, temporary audit)
  update_custom/run.sh # non-regression of update_custom_run (FORCE=yes, no audit=, missing script, script OK, script failing, help), the user script is saved and put back
  generated-db/run.sh # non-regression of the generated databases (database/db_info.txt, database/db_exception.txt): every target reading one has its rule as prerequisite, a missing file is rebuilt (`catalog_build`, `exceptions_build`), also by `check_repo`/`check_run` with CATALOG_BUILD=no; files saved and put back
  nist-reference/run.sh # non-regression of the working copy of the shipped NIST reference (common/database/db_nist800-53.txt -> database/, rule `$(NIST_REFERENCE)`): every target reading it has it as prerequisite (`catalog_build*`, `check_database`, `check_integrity`, `nist_coverage_official`, `check_repo`, `check_run`), missing/modified/older copy replaced, up to date copy untouched; database file and .orig saved and put back
  vars/run.sh         # non-regression of the variables: every variable only in support/Makefile.support.vars.mk (first include of Makefile), explained by `gmake help vars`, every option described in docs/CAWK_OPTIONS.md
  archive-guard/run.sh # non-regression of the archive protection (clean_archive_* age rule >= 30 days, ALL_ARCHIVE=yes FORCE=yes, check_archive_guard refusing check over the archives of reports/run*), in a temporary audit
  summary-html/run.sh # non-regression of the consistency between assessment.all.summary.txt and .html (number_of_* embedded as `stats`, recs and exceptions summed by status and risk, `checks` = results + exceptions, psirt_clear), in a temporary audit
  data_set/run.sh     # non-regression of the data_set of an audit (create_audit, one file per date, same-date replacement, DATA_SET_KEEP rotation, errors, check_database, html dashboard, backup, delete_audit), in a temporary audit
  hypercube-ipv6/     # non-regression of common_hypercube-lib.gawk (rules cube): one case directory per rule pair, `run.sh [record]`
  test-sync/
    source/         # Fixture config files for sync pipeline testing
    scope.txt       # Device allow-list for sync scope validation

logs/
  repo/, run/, run_<audit>/   # Assessment execution logs (purged by clean_logs_*)
  <context>.censored/          # Generated by censor_logs_* (never read by assessments)

reports/
  repo/, run/, run_<audit>/   # Assessment output + archives/
  <context>.censored/          # Generated by censor_report_* (the reports hold conf lines)

common/             # cawk SYSTEM side (shipped with each version, never saved nor restored, do not edit): shared gawk function libraries, scripts, shipped rules and reference files
  common.gawk.template              # Core functions: print_err(), rm_last_char()
  common_hypercube-lib.gawk.template # Network/IP/CIDR utility functions
  report.gawk.template              # Report generation logic
  report_html.gawk.template         # Standalone html report generator (HTML=yes), embeds counters (and the data_set of a named audit) in report_html.skeleton.html
  test_generic_psirt.gawk.template  # PSIRT test base template
  censor/censor_regex_core.m4       # Censor rules shipped by cawk (included by database/censor/censor_regex.m4); censor/censor_regex.m4 is the template of the installation file
  censor.gawk.template              # Configuration censoring (regexes: shipped rules in common/censor/censor_regex_core.m4, rules of an installation in database/censor/censor_regex.m4 which includes the core)
  database/db_nist800-53.txt        # NIST 800-53 reference shipped by cawk, copied to database/ (check_integrity) when the copy is missing or older
  data_set.script.sh                # Writes the data_set of a named audit (init, append): cawk system code, run by create_audit and check_run audit=
  check_database.script.sh          # Format check of every database (gmake check_database): cawk system code

m4/                 # M4 macro library for block-parse templates
support/
  tests.sed         # Sed substitution rules for template compilation
database/           # USER side: flat-file databases for sync, collect, email, post-audit config, the rules and scripts the user edits
  data_set/         # run_<audit>/data_set_<audit>_YYYY-MM-DD.txt: one file (one line of key values) per date and per named audit (script common/data_set.script.sh, not versioned)
  collectors/       # Optional external config collectors (scp, rsync: automatic copy from a central unix/linux system; local: cp from a directory of the cawk machine), run directly (not compiled)
```

## Supported Suppliers

Tests and confs are organized per supplier. Current scope (defined in `Makefile` and support files):

`cisco-ios`, `cisco-xr`, `cisco-xe`, `cisco-cedge`, `cisco-viptela`, `cisco-sdnios`, `juniper-junos`, `huawei-vrp`, `fortinet-fortios`, `nokia-sros`, `paloalto-panos`, `checkpoint-fwcli`, `packetfilter-fwcli`, `iptables-fwcli`, `6wind-linux`, `ekinops-oneos`

## Test Naming Convention

Test filenames follow a strict pattern:

```
<category>_<check>_<status>.<supplier>.gawk.<format>
```

| Segment | Description | Examples |
|---------|-------------|---------|
| `<category>` | Security domain | `aaa`, `acl`, `snmp`, `ntp`, `crypto` |
| `<check>` | What is being checked (compound words concatenated) | `user`, `userclass`, `community`, `defref` |
| `<status>` | Expected state: `set` (must be present) or `notset` (must be absent) | `set`, `notset` |
| `<supplier>` | Vendor/platform (see [Supported Suppliers](#supported-suppliers)) | `cisco-ios`, `juniper-junos` |
| `<format>` | Source format | `template`, `m4`, `include` |

**Examples:**

- `aaa_user_notset.juniper-junos.gawk.template` — forbidden AAA users must not exist
- `aaa_userclass_notset.juniper-junos.gawk.template` — user class must be assigned
- `acl_defref_set.cisco-ios.gawk.template` — ACL definitions must be referenced
- `snmp_community_notset.cisco-xe.gawk.m4` — default SNMP communities must not exist

**Important:** The `@test_name` metadata tag must match the compiled filename (without the source format extension), e.g., `aaa_userclass_notset.juniper-junos.gawk`.

## Writing a New Test

1. Create `tests/repo/tests.<supplier>/<test_name>.<supplier>.gawk.<format>` (see [Test Naming Convention](#test-naming-convention) above)
2. Use `%SED_GAWK_PATH%` as shebang and `%SED_INCLUDE_PATH%` for the include
3. Include metadata comments with format `# @tag : value`:
   - `@test_name` — Unique test identifier (must match compiled filename)
   - `@supplier` — Vendor/platform (e.g., `cisco-ios`, `juniper-junos`)
   - `@purpose` — One-line purpose of the test
   - `@description` — Detailed description of what the test checks
   - `@risk_level` — Single level (`high`/`medium`/`low`/`info`) or pipe-separated list for multi-aspect tests (e.g., `high | info`)
   - `@actions` — Recommended remediation steps
   - `@nist800-53_ref` — NIST 800-53 control reference (use `|` as separator, e.g., `CM-7(1) | Configuration Management | Ensure ...`)
   - `@authors` — Test authors (comma-separated if multiple)

   **Note:** Use `|` (pipe) as separator for multi-value metadata fields, not commas.

4. Output lines using `print_err()` from common.gawk with format: `conf_name|test_name|error_line|line_nb|risk_level|status_code`
5. Valid status codes: `pass`, `error`, `warning`, `psirt`
6. Run `gmake tests_repo` to compile, then `gmake check_repo` to validate

## Build System Architecture

The cawk build system has been modularized into focused Makefile support files for maintainability:

| File | Purpose |
|------|---------|
| `Makefile` | Main entry point; includes all support files |
| `support/Makefile.support.vars.mk` | Every global variable (paths, options, supplier lists, generated per-supplier variables, helpers), the only file defining variables, included first by `Makefile`; explained by `gmake help vars` (`help_vars`), checked by `validate/vars` |
| `support/Makefile.support.cmdline.mk` | Unknown `NAME=value` on the command line (not a variable of `vars.mk` nor in `CMDLINE_PARAMS`): `cawk error: unknown option <X>, did you mean: ...` and stop at parse time, before any target (included right after `vars.mk`, tested by `validate/messages`) |
| `support/Makefile.support.mk` | Compilation pattern rules and assessment macros (no variable) |
| `support/Makefile.support.help.mk` | Help (one `help_<section>` target per section: `gmake help`, `gmake help <section>`, `gmake help all`, `gmake help topic=WORD`) and the unknown target message with similar targets (`.DEFAULT`, `support/similar_target.awk`) |
| `support/cawk-completion.bash` | Optional bash completion (targets cached in `tmp/cawk_targets.cache`, `audit=`, `supplier=`, the yes/no options read from `vars.mk`, `CENSOR_LEVEL=`, `collector=`, `topic=`), tested by `validate/completion` |
| `support/Makefile.support.audit.mk` | Audit creation/deletion/management targets, `status` (report built by `support/audit_status.sh`), `check_audit` (early audit= validation, first prerequisite of the audit= targets with a heavy chain) |
| `support/Makefile.support.supplier.mk` | Supplier and option validation targets: `check_supplier` (options yes/no and >= 1, audit name charset), `supplier`, `system`, `common` |
| `support/Makefile.support.database.mk` | Database entry management targets |
| `support/Makefile.support.postaudit.mk` | Post-audit execution targets |
| `support/Makefile.support.email.mk` | Email notification targets |
| `support/Makefile.support.backup.mk` | Backup, restore, and migrate targets |
| `support/Makefile.support.custom.mk` | `update_custom_run` (FORCE=yes): runs the user script `database/scripts/update_custom.script.sh` after a cawk update, global, no `audit=`, never run by `check*` |
| `support/Makefile.support.sync.mk` | Config synchronization targets |
| `support/Makefile.support.collect.mk` | Optional config collectors: `collect_run`, `collect_run_audit`, `database_collect_(add,update,del,sync)`, `check_collect` |
| `support/Makefile.support.tests.mk` | Test compilation and validation targets |
| `support/Makefile.support.deprecated.mk` | Deprecated detection: test functions (`DEPRECATED_FUNCTIONS` regex) and files moved by a release (`DEPRECATED_FILES` old:new pairs, `check_deprecated_files`), `check_censor_core`, `check_integrity` (first prerequisite of `check_repo`/`check_run`, shows `cawk error:` without exit 1, `INTEGRITY_FATAL`), `check_deprecated_repo`/`check_deprecated_run`; the action is to remove the pointed element |
| `support/Makefile.support.view.mk` | Report viewing targets (view_repo, view_run, errors) |
| `support/Makefile.support.archive.mk` | Archive management targets |
| `support/Makefile.support.clean.mk` | Cleanup targets (reports, backups, temporary files, `clean_censor_*`) |
| `support/Makefile.support.catalog.mk` | Test catalog and NIST mapping targets |
| `support/Makefile.support.censor.mk` | Configuration censoring targets (`censor_repo`, `censor_run`, `censor_run_audit`, `censor_file`, `censor_stdout`, `censor_check`, `censor_logs_*`, `censor_report_*`) |
| `support/Makefile.support.exceptions.mk` | Exception rule management targets |
| `support/Makefile.support.check.mk` | Assessment and validation targets (repo, run, audit) |
| `support/Makefile.support.check.scope.mk` | `check_repo` and `check_run`: one `cawk_check_body` canned recipe for the 12 cases (repo\|run\|audit x suppliers x sequential\|parallel) |
| `support/Makefile.support.check.track.mk` | `check_track` (check run through the `checkdiff/track/scripts/trace_shell.sh` SHELL wrapper: per-phase trace, counted-content snapshots and last recipe line in `checkdiff/track/trace`, not versioned, with a self-test of the trace against `checkdiff.new`), `check_track_explain`, `check_track_update` (reference in `checkdiff/track/ref`, versioned), `clean_track` |
| `support/Makefile.support.git.mk` | Git-related targets (commit, push, CI/CD integration) |
| `support/Makefile.support.role.mk` | Roles targets (`roles_list`, `roles_perm` running `roles/cawk_perm`) |

### Key Configuration: support/Makefile.support.vars.mk

Global options (`MAKE_PARALLEL`, `PSIRT_ONLY`, `CENSOR_LEVEL`, `SECRETSCAN`, `HTML`, ...): see [docs/CAWK_OPTIONS.md](docs/CAWK_OPTIONS.md). Any option can be overridden per invocation, e.g. `gmake check_run audit=client1 PSIRT_ONLY=yes JSON=yes`.

## Assessment Types

- **repo** — runs against `tests/repo/` + `confs/repo/` — used for self-testing and demo
- **run** — runs against `tests/run/` + `confs/run/` — default working assessment
- **run_`<audit>`** — named audit with isolated tests/confs/exceptions/reports; created with `create_audit`

Named audits (`audit=AUDIT_NAME`) are the primary workflow for real network assessments.

## Database Format

Flat files in `database/` (`data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt` per date of a named audit, `db_sync`, `db_collect`, `db_email`, `db_postaudit`, `db_info` generated, `censor_regex` generated from `common/censor/censor_regex_core.m4` (shipped) and `database/censor/censor_regex.m4` (the rules of the installation, includes the core, the only file to edit); `db_nist800-53.txt` is the working copy of `common/database/db_nist800-53.txt`): fields and examples in [docs/CAWK_DATABASE_FORMAT.md](docs/CAWK_DATABASE_FORMAT.md). `db_info.txt` and `censor_regex` must never be edited manually. The format of every `.txt` database is checked one by one by `gmake check_database` (also a phase of `gmake check`, implemented in `common/check_database.script.sh`): one explicit error per bad line, exit 1 when a database holds at least one.
