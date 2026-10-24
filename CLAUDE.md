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
# Show all available targets
gmake

# Show cawk version
gmake version

# Run integrity check (before first use after install)
gmake check

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
gmake delete_audit audit=client1

# List all named audits
gmake list_audit

# Optional config collectors (confs/collect_<audit>, linked by the sync into confs/run_<audit>)
gmake database_collect_add audit=client1 collector=rsync args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519 sync=yes
gmake collect_run audit=client1
gmake collect_run_audit
gmake sync_run audit=client1 COLLECT=yes
gmake check_collect

# Clean generated files
gmake clean

# FORCE=yes is required by clean_logs*, clean_orig, clean_force and every git* target (gitcheck* excepted)
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

Tests are **never written as `.gawk` directly**. They are authored as one of three source formats and compiled at build time:

| Source format | Compiled via | Use case |
|---|---|---|
| `*.gawk.template` | `sed` (support/tests.sed) | Standard tests |
| `*.gawk.m4` | `m4` then `sed` | Tests needing M4 block-parse macros |
| `*.gawk.include` | `sed` (PSIRT mode) | PSIRT vulnerability tests |

The build rule (defined in the Makefile support files, see below) converts these to `*.gawk` files. The sed rules in `support/tests.sed` substitute vendor-specific placeholders (e.g., `%SED_GAWK_PATH%`, `%SED_AUTHUSER_CISCO%`) with system/vendor-specific values.

Placeholders `%SED_*` (defined in `support/tests.sed`): see [docs/CAWK_SED_PLACEHOLDERS.md](docs/CAWK_SED_PLACEHOLDERS.md).

## Directory Layout

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

validate/
  censor/run.sh       # non-regression of censor_regex.m4: validate/censor/cases.tsv, secrets censored and benign lines intact at both levels
  test-sync/
    source/         # Fixture config files for sync pipeline testing
    scope.txt       # Device allow-list for sync scope validation

logs/
  repo/, run/, run_<audit>/   # Assessment execution logs (purged by clean_logs_*)
  <context>.censored/          # Generated by censor_logs_* (never read by assessments)

reports/
  repo/, run/, run_<audit>/   # Assessment output + archives/
  <context>.censored/          # Generated by censor_report_* (the reports hold conf lines)

common/             # Shared gawk function libraries
  common.gawk.template              # Core functions: print_err(), rm_last_char()
  common_hypercube-lib.gawk.template # Network/IP/CIDR utility functions
  report.gawk.template              # Report generation logic
  report_html.gawk.template         # Standalone html report generator (HTML=yes), embeds counters in report_html.skeleton.html
  test_generic_psirt.gawk.template  # PSIRT test base template
  censor.gawk.template              # Configuration censoring (regexes: edit database/censor/censor_regex.m4 only)

m4/                 # M4 macro library for block-parse templates
support/
  tests.sed         # Sed substitution rules for template compilation
database/           # Flat-file databases for sync, collect, email, post-audit config
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
| `support/Makefile.support.mk` | Core variables, paths, options, and compilation rules |
| `support/Makefile.support.help.mk` | Help and information targets |
| `support/Makefile.support.audit.mk` | Audit creation/deletion/management targets |
| `support/Makefile.support.database.mk` | Database entry management targets |
| `support/Makefile.support.postaudit.mk` | Post-audit execution targets |
| `support/Makefile.support.email.mk` | Email notification targets |
| `support/Makefile.support.backup.mk` | Backup, restore, and migrate targets |
| `support/Makefile.support.sync.mk` | Config synchronization targets |
| `support/Makefile.support.collect.mk` | Optional config collectors: `collect_run`, `collect_run_audit`, `database_collect_(add,update,del,sync)`, `check_collect` |
| `support/Makefile.support.tests.mk` | Test compilation and validation targets |
| `support/Makefile.support.deprecated.mk` | Deprecated test function detection (`DEPRECATED_FUNCTIONS` regex, `check_deprecated_repo`/`check_deprecated_run`) |
| `support/Makefile.support.view.mk` | Report viewing targets (view_repo, view_run, errors) |
| `support/Makefile.support.archive.mk` | Archive management targets |
| `support/Makefile.support.clean.mk` | Cleanup targets (reports, backups, temporary files, `clean_censor_*`) |
| `support/Makefile.support.catalog.mk` | Test catalog and NIST mapping targets |
| `support/Makefile.support.censor.mk` | Configuration censoring targets (`censor_repo`, `censor_run`, `censor_run_audit`, `censor_file`, `censor_stdout`, `censor_check`, `censor_logs_*`, `censor_report_*`) |
| `support/Makefile.support.exceptions.mk` | Exception rule management targets |
| `support/Makefile.support.check.mk` | Assessment and validation targets (repo, run, audit) |
| `support/Makefile.support.check.scope.mk` | `check_repo` and `check_run`: one `cawk_check_body` canned recipe for the 12 cases (repo\|run\|audit x suppliers x sequential\|parallel) |
| `support/Makefile.support.git.mk` | Git-related targets (commit, push, CI/CD integration) |

### Key Configuration: support/Makefile.support.mk

Global options (`MAKE_PARALLEL`, `PSIRT_ONLY`, `CENSOR_LEVEL`, `SECRETSCAN`, `HTML`, ...): see [docs/CAWK_OPTIONS.md](docs/CAWK_OPTIONS.md). Any option can be overridden per invocation, e.g. `gmake check_run audit=client1 PSIRT_ONLY=yes JSON=yes`.

## Assessment Types

- **repo** — runs against `tests/repo/` + `confs/repo/` — used for self-testing and demo
- **run** — runs against `tests/run/` + `confs/run/` — default working assessment
- **run_`<audit>`** — named audit with isolated tests/confs/exceptions/reports; created with `create_audit`

Named audits (`audit=AUDIT_NAME`) are the primary workflow for real network assessments.

## Database Format

Flat files in `database/` (`db_sync`, `db_collect`, `db_email`, `db_postaudit`, `db_info` generated, `censor_regex` generated from `database/censor/censor_regex.m4`, the only file to edit): fields and examples in [docs/CAWK_DATABASE_FORMAT.md](docs/CAWK_DATABASE_FORMAT.md). `db_info.txt` and `censor_regex` must never be edited manually.
