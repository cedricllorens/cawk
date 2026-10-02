# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. It is the single source of truth for both the **technical reference** (architecture, commands, formats) and the **development practices** (how to work safely and consistently on cawk).

## Important: Git Workflow

**Claude Code must NOT create git commits.** Commits, pushes, and branch management are done manually by the user.

Claude Code should:

- ✅ Create `.orig` backups before modifying files
- ✅ Review changes with `git diff` and `git status`
- ✅ Update ChangeLog and README as needed
- ❌ **NOT create commits** — user will do this manually
- ❌ **NOT push to remote** — user will do this manually
- ❌ **NOT create or switch branches** — user will do this manually

See [Git Workflow Details](#git-workflow-details) below for the commit message format and the full division of responsibilities.

## Core Tools

cawk relies exclusively on three tools — no other languages or dependencies:

- `gawk` (GNU AWK) — test execution engine
- `gmake` (GNU Make) — build system and task runner
- `m4` (GNU M4) — macro expansion for test templates

All commands use `gmake`, not `make`.

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

# Clean generated files
gmake clean

# Clean persisted execution logs (not touched by gmake clean)
gmake clean_logs_repo
gmake clean_logs_run
gmake clean_logs_run audit=client1
gmake clean_logs_run_audit
```

## Test Template Pipeline

Tests are **never written as `.gawk` directly**. They are authored as one of three source formats and compiled at build time:

| Source format | Compiled via | Use case |
|---|---|---|
| `*.gawk.template` | `sed` (support/tests.sed) | Standard tests |
| `*.gawk.m4` | `m4` then `sed` | Tests needing M4 block-parse macros |
| `*.gawk.include` | `sed` (PSIRT mode) | PSIRT vulnerability tests |

The build rule (defined in the Makefile support files, see below) converts these to `*.gawk` files. The sed rules in `support/tests.sed` substitute vendor-specific placeholders (e.g., `%SED_GAWK_PATH%`, `%SED_AUTHUSER_CISCO%`) with system/vendor-specific values.

Key `%SED_*` placeholders (defined in `support/tests.sed`):

**Core paths:**
- `%SED_GAWK_PATH%` — shebang path for gawk
- `%SED_INCLUDE_PATH%` — path to `common/common.gawk`
- `%SED_INCLUDE_PATH_FWLIB%` — path to `common/common_hypercube-lib.gawk`

**Block indentation (vendor-specific):**
- `%SED_BK_JUNI%` — block indentation for Juniper Junos
- `%SED_BK_NOKIA%` — block indentation for Nokia SROS
- `%SED_BK_FORTI%` — block indentation for Fortinet FortiOS
- `%SED_BK_PALO%` — block indentation for Palo Alto PAN-OS
- `%SED_BK_WIND%` — block indentation for 6wind-linux

**Authorized admin user patterns (vendor-specific):**
- `%SED_AUTHUSER_CISCO%` — Cisco IOS/XE/XR authorized admin user pattern
- `%SED_AUTHUSER_FORTI%` — Fortinet FortiOS authorized admin user pattern
- `%SED_AUTHUSER_JUNI%` — Juniper Junos authorized admin user pattern
- `%SED_AUTHUSER_NOKIA%` — Nokia SROS authorized admin user pattern
- `%SED_AUTHUSER_CEDGE%` — Cisco Catalyst Edge authorized admin user pattern
- `%SED_AUTHUSER_HUAWEI%` — Huawei VRP authorized admin user pattern
- `%SED_AUTHUSER_VIPTELA%` — Cisco Viptela authorized admin user pattern

**AAA system patterns (vendor-specific):**
- `%SED_AAASYSTEM_JUNI%` — Juniper Junos AAA system patterns
- `%SED_AAASYSTEM_NOKIA%` — Nokia SROS AAA system patterns

**Forbidden protocols (vendor-specific):**
- `%SED_FORBIDPROTO_FORTI%` — Fortinet FortiOS forbidden protocols
- `%SED_FORBIDPROTO_NOKIA%` — Nokia SROS forbidden protocols
- `%SED_FORBIDPROTO_PALO%` — Palo Alto PAN-OS forbidden protocols
- `%SED_FORBIDPROTO_VIPTELA%` — Cisco Viptela forbidden protocols

**Management interface patterns:**
- `%SED_MGNT_KW%` — management interface keywords pattern
- `%SED_MGNT_BADPROTO%` — forbidden protocols for management interfaces

**Security patterns:**
- `%SED_OLD_CRYPTO%` — old/deprecated cryptography patterns
- `%SED_SNMP_FORBID_COMMUNITY%` — SNMP forbidden community strings

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

exceptions/
  repo/             # Exception rules (applied during reporting)
  run/, run_<audit>/

validate/
  test-sync/
    source/         # Fixture config files for sync pipeline testing
    scope.txt       # Device allow-list for sync scope validation

reports/
  repo/, run/, run_<audit>/   # Assessment output + archives/

common/             # Shared gawk function libraries
  common.gawk.template              # Core functions: print_err(), rm_last_char()
  common_hypercube-lib.gawk.template # Network/IP/CIDR utility functions
  report.gawk.template              # Report generation logic
  test_generic_psirt.gawk.template  # PSIRT test base template

m4/                 # M4 macro library for block-parse templates
support/
  tests.sed         # Sed substitution rules for template compilation
database/           # Flat-file databases for sync, email, post-audit config
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

### M4 Block Macro Best Practices

When using M4 templates with `m4_cawk_parse_block()` macro (for interface or block-level iteration):

**✅ CORRECT: Single Combined Regex with Inline Processing**

```awk
m4_cawk_parse_block(

dnl level 0 - interface/block start/end
`/^interface .*$/',`
	interface = $0;
	block_var1 = 0;
	block_var2 = 0;
',
`/^!$/', `
	if ( block_var1 == 1 && block_var2 == 0 ) {
		print_err(...);
		pass = 0;
	}
',

dnl level 1 - SINGLE combined pattern with inline if statements
`/^ (pattern1|pattern2)/',`
	if ($0 ~ /^ pattern1/) block_var1 = 1;
	if ($0 ~ /^ pattern2/) block_var2 = 1;
',
`', `'

)
```

**❌ WRONG: Multiple Separate Level-1 Patterns**

```awk
dnl AVOID THIS - causes bl_level state confusion
`/^ pattern1/',`block_var1 = 1;',
`/^ pattern2/',`block_var2 = 1;',
`', `'
```

**Why:** Multiple level-1 patterns cause the M4 macro to generate conflicting `bl_level` state changes, breaking block-end detection. Use a single combined regex pattern with inline `if` statements instead. To exclude whole blocks (e.g. skip `[Ll]oopback` interfaces, or Juniper `inactive:` stanzas), add the condition to the block's own begin hook (e.g. `/^interface .*$/ && !/[Ll]oopback/`, or `/%SED_BK_JUNI%[^ ]+ {/ && !/inactive/` for Juniper physical interfaces) rather than a flag checked at block-end — the begin action never fires, so `bl_level` never advances and nothing inside the block is tracked. Add the exclusion once at the begin hook that opens the block to skip, not repeated at every nested hook underneath it.

### acl_configconsistency_set Golden Rule: No Wrapper Around cawk_add_hypercube_rules()

**Applies only to the `acl_configconsistency_set.<supplier>` tests.** In these tests, `cawk_add_hypercube_rules()` must be called **directly** at the point where a rule is emitted. Never introduce a per-supplier wrapper function (`pf_add_rule()`, `cisco_add_rule()`, …) that forwards its 14+ arguments to it.

**❌ WRONG:**

```awk
function pf_add_rule(rule_desc, action, inoutgress, interface, family, src_ip, ... , protocol,    icmp_k) {
	if ( protocol != "icmp" || length(table_icmp) == 0 ) {
		cawk_add_hypercube_rules("...gawk", rule_desc, ... , protocol);
		return;
	}
	for ( icmp_k in table_icmp ) cawk_add_hypercube_rules("...gawk", rule_desc, ... , protocol, icmp_k);
}
...
pf_add_rule(rule_desc, action, inoutgress, interface, family, src_ip, ... , protocol);
```

**✅ CORRECT** — emit from the combinatory loops themselves, expanding extra dimensions (icmp type/code, port intervals, …) inline:

```awk
for (id2 in table_protocol) {

	protocol = table_protocol[id2];

	# an icmp rule restricted to some icmp messages yields one rule per message ----
	if ( protocol == "icmp" && length(table_icmp) > 0 ) {
		for (id3 in table_icmp) {
			cawk_add_hypercube_rules("...gawk", rule_desc, ... , protocol, id3);
		}
	} else {
		cawk_add_hypercube_rules("...gawk", rule_desc, ... , protocol);
	}
}
```

**Why:** the whole point of these tests is that every rule pushed into the hypercube is visible at its emission site. A wrapper re-declares the full argument list a second time, so any change to `cawk_add_hypercube_rules()` (a new dimension, a reordered argument) must be mirrored in every wrapper of every supplier — and a silent mismatch shifts arguments without an AWK error, producing wrong `inconsistent`/`redundant` verdicts that look like parsing bugs. It also hides the rule combinatory (address × port × protocol × icmp) that the loops are there to express.

**How to apply:** if the same call appears several times, collapse the *loops* (hoist the assignments that differ, as the `dst_port` / `src_port` blocks do) rather than extracting a function. Small **parsing** helpers that return a value and take few arguments stay welcome (e.g. `pf_icmp_add()`, `cisco_port_intervals()`, `huawei_port()`) — the rule targets only wrappers around the cube-insertion call.

See [Working with Tests](#working-with-tests) for the full workflow on creating, modifying, and validating tests.

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
| `support/Makefile.support.tests.mk` | Test compilation and validation targets |
| `support/Makefile.support.deprecated.mk` | Deprecated test function detection (`DEPRECATED_FUNCTIONS` regex, `check_deprecated_repo`/`check_deprecated_run`) |
| `support/Makefile.support.view.mk` | Report viewing targets (view_repo, view_run, errors) |
| `support/Makefile.support.archive.mk` | Archive management targets |
| `support/Makefile.support.clean.mk` | Cleanup targets (reports, backups, temporary files) |
| `support/Makefile.support.catalog.mk` | Test catalog and NIST mapping targets |
| `support/Makefile.support.exceptions.mk` | Exception rule management targets |
| `support/Makefile.support.check.mk` | Assessment and validation targets (repo, run, audit) |
| `support/Makefile.support.git.mk` | Git-related targets (commit, push, CI/CD integration) |

### Key Configuration: support/Makefile.support.mk

Global options that affect all assessments (defined in `support/Makefile.support.mk`):

| Option | Values | Default | Purpose |
|--------|--------|---------|---------|
| `CAWK_RELEASE` | version string | (varies) | Current cawk release version |
| `MAKE_PARALLEL` | `yes` / `no` | `no` | Spawn multiple make jobs for parallel test execution |
| `MAKE_J` / `MAKE_FILES_PER_TARGET` | number | 4 / 100 | Parallel job count and config files per target job |
| `MAKE_FILES_PER_TARGET_MAX` | number | 2000 | Safety ceiling for `MAKE_FILES_PER_TARGET`/`MAKE_FILES_PER_TARGET_PSIRT` (see Makefile Gotchas — ARG_MAX) |
| `PSIRT_ONLY` | `yes` / `no` | `no` | Assessment mode: `no` = standard **plus** PSIRT tests; `yes` = PSIRT tests **only** (standard skipped). PSIRT tests are always compiled; this flag only selects which run. |
| `DEADBEEF` | `yes` / `no` | `no` | Flag configs older than threshold |
| `DEADBEEF_THRESHOLD_DAYS` | number | 30 | Days to consider a config "old" |
| `BADFORMAT` | `yes` / `no` | `no` | Exclude badformat configs (first-level indentation violations, detected by `common/badformat_cawk_conf.gawk`) from the final reports; the badformat scan itself always runs |
| `CRLF` | `yes` / `no` | `yes` | Exclude crlf configs (windows format, detected by `common/crlf_cawk_conf.gawk`) from the final reports — forced to `yes` by default since CRLF results are wrong; the crlf scan itself always runs |
| `JSON` | `yes` / `no` | `no` | Generate JSON reports alongside text |
| `CATALOG_BUILD` | `yes` / `no` | `no` | Rebuild test catalog (db_info.txt) before assessment |
| `ARCHIVE_OLDER_DAYS` | number | 120 | Auto-cleanup of old report archives |

All options can be overridden per-invocation:

```bash
gmake check_run audit=client1 PSIRT_ONLY=yes JSON=yes DEADBEEF_THRESHOLD_DAYS=180
```

## Makefile Gotchas & Conventions

Hard-won lessons when editing the Makefile — verify against these before changing recipe logic:

- **`check_repo` and `check_run` bodies are duplicated ~12×** (across the supplier × parallel × audit branches). The tail is factored into the `cawk_report_tail` canned recipe, but the collection/exception/summary blocks are copy-pasted and **drift easily**. When you change one branch, mirror the change across all matching branches, and diff `repo` vs `run` variants to keep them aligned.
- **`$(findstring x,LIST)` matches substrings, not words.** For membership validation (e.g. `supplier=`), use `$(filter x,LIST)` which compares whole space-separated words. `findstring` wrongly accepted partial names like `cisco`, `ios`, `juni`.
- **`ECHO = echo` has no `-e`.** Do not rely on `\n` inside `$(ECHO) "...\n..."` — interpretation depends on the shell (`dash` expands, `bash` doesn't). Use one `$(ECHO)` per line instead.
- **`exit 0` in an error branch masks the failure** — the recipe (and any prerequisite like `check_supplier`) reports success, so callers/CI can't detect it and assessments silently produce empty reports. Use `exit 1` for genuine user errors. Note that each recipe line runs in its own shell: an `exit 0` standing alone on its line (e.g. after an `ifeq` error message) ends only that line, and Make then **continues with the next recipe lines** — only a non-zero exit stops the recipe.
- **`PSIRT_ONLY` (formerly `PSIRT`) is an assessment *mode*, not an enable flag** — see the options table. PSIRT `.gawk` are always compiled; `PSIRT_ONLY=yes` runs them *exclusively*. The old `PSIRT` name is rejected by `check_supplier` with a `cawk error:` so a stale `PSIRT=yes` cannot silently run all tests.
- **Prefer `find … -exec cmd {} +` over `-exec cmd {} \;`** when `cmd` accepts several files (`grep`, `touch`, `deadbeef_cawk_conf.script`): `\;` forks one process per file, which dominates run time at audit scale. Keep `\;` only for commands that take exactly one file.
- **Quoted shell globs don't expand**: `[ -d "$(TESTS_PATH)/run_*" ]` is always false (literal `run_*`). Prefer an unguarded `find $(TESTS_PATH)/run_* ... 2>/dev/null || true`, matching the style already used elsewhere in `clean`.
- **Anchor audit-name matching.** `sed`/`grep` on an audit name must be anchored (trailing space for space-separated DBs, `$` for one-name-per-line), otherwise `client1` also matches `client1_backup` / `client10`. Likewise avoid `run_${audit}*` globs in backup/delete recipes.
- **`archive_repo` archives into `reports/repo/archives/`** (not `run/`); keep the `tar` destination and the echoed path in sync.
- **`MAKE_PARALLEL=yes` recipes are not `ARG_MAX`-safe by default.** The sequential path (`cawk_test_execution`) uses `find -exec ./test {} +`, which `find` batches automatically to respect the OS argument-length limit. `common/gen_cawk_makefile(.psirt).gawk` (used by `cawk_test_gen_parallel` and the parallel PSIRT branches) instead concatenates up to `MAKE_FILES_PER_TARGET`/`MAKE_FILES_PER_TARGET_PSIRT` config paths literally into one recipe line — no batching. `check_supplier` enforces `MAKE_FILES_PER_TARGET_MAX` (default 2000) as a ceiling; don't remove that check or raise the ceiling without re-checking against a realistic `ARG_MAX` (varies by OS/container, `getconf ARG_MAX`). A failure here surfaces as a `cawk warning:` line (stderr captured to `$(LOGS_PATH)/parallel_gmake.<scope>.err`, i.e. `logs/parallel_gmake.<scope>.err` — persists across runs, unlike `tmp/`; purge explicitly with `gmake clean_logs`), not a hard stop — keep it that way so one supplier's failure doesn't abort the whole assessment.

## Configuration Variables: Make ↔ Shell Consistency

**CRITICAL RULE: Path variables defined in `support/Makefile.support.mk` MUST be kept in sync with `database/include/scripts_config.sh`.**

These files are the source of truth for directory paths used across cawk:

| Variable | Makefile (Make syntax) | Shell Script (POSIX syntax) | Purpose |
|----------|---------|--------|---------|
| `CONFS_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Configuration directory |
| `COMMON_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Common AWK libraries |
| `BACKUP_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Backup archives |
| `DATABASE_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Flat-file databases |
| `LOGS_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Logs directory |
| `REPORT_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Generated reports |
| `EXCEPTION_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Exception rules |
| `TESTS_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Test templates |
| `TESTS_COMMON_PATH` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Common test libraries |
| `TESTS_SYSTEM` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | System tests |
| `TESTS_TMP` | `support/Makefile.support.mk` | `database/include/scripts_config.sh` | Temporary test files |
| `DATABASE_PATH/db_info.txt` | `DATABASE_CIS_INFO` in Makefile | `database/include/scripts_config.sh` | Test catalog |

### Why This Matters

Shell scripts (`.script.sh`) source `database/include/scripts_config.sh` to access these paths; Make targets read them from `support/Makefile.support.mk`. When values drift:

- Shell scripts may operate on wrong directories
- Assessments can fail silently or produce incomplete results
- Database sync/post-audit operations may target incorrect locations

### Enforcement

**When adding or modifying a path variable:**

1. Edit `support/Makefile.support.mk` (Make version)
2. Edit `database/include/scripts_config.sh` (POSIX shell version)
3. Verify both define identical paths: `grep "^CONFS_PATH" support/Makefile.support.mk database/include/scripts_config.sh`
4. Update `ChangeLog.md` with the change
5. Run `gmake check_repo` to validate the build system

**Gotcha:** Variable names are identical (`CONFS_PATH`, not `MAKE_CONFS_PATH` vs `SH_CONFS_PATH`), but their syntax differs:
- Make: `CONFS_PATH = confs` (spaces around `=`)
- Shell: `CONFS_PATH="confs"` (quotes, no spaces)

The shell version also includes helper functions like `get_database_scripts()` to expand glob patterns (Make's `$(wildcard ...)` equivalent in POSIX shell).

## Assessment Types

- **repo** — runs against `tests/repo/` + `confs/repo/` — used for self-testing and demo
- **run** — runs against `tests/run/` + `confs/run/` — default working assessment
- **run_`<audit>`** — named audit with isolated tests/confs/exceptions/reports; created with `create_audit`

Named audits (`audit=AUDIT_NAME`) are the primary workflow for real network assessments.

## Database Format

cawk uses flat-file databases stored in the `database/` directory for managing audit-specific configurations and metadata.

### db_sync.txt

Stores configuration for automatic config synchronization across devices.

**Format:** Space-separated fields (7 fields). Each field must contain no spaces; multi-value fields use commas as the internal sub-separator.

- Field 1: `audit_name` — Name of the audit context (matches `audit=AUDIT_NAME`)
- Field 2: `sync_paths` — Comma-separated list of remote paths to sync (e.g., `/conf/,/conf/backup/`)
- Field 3: `inventory_regex` — Extended regex pattern a `scope_file` line (field 4) must match to be kept as an allowed device. **Only applied when `scope_file` is set** — if `scope_file` is `none`, this field has no effect and every file found under `sync_paths` is synced (see [`sync_cawk_conf.gawk.template`](common/sync_cawk_conf.gawk.template))
- Field 4: `scope_file` — File path containing device inventory scope (one entry per line; only the first whitespace-separated column is used as the device path), or `none` for all devices
- Field 5: `os_regex` — Extended regex pattern to match OS types (e.g., `(cisco-ios|cisco-xe)`)
- Field 6: `path_exclude` — Extended regex pattern to exclude paths (e.g., `_backup`), or `none` for no exclusions
- Field 7: `inventory_regex_exclude` — Extended regex pattern a `scope_file` line must **not** match to be kept, or `none` for no exclusion. Same "only applies with `scope_file`" restriction as field 3

**Example:**

```text
client1 /conf/,/conf/cawk/ .*switch.* /inventory/scope.txt cisco-ios|cisco-xe _backup none
```

**Created by:** `gmake database_sync_add audit=AUDIT_NAME ...`

### db_email.txt

Stores email notification configuration for each audit context.

**Format:** Space-separated fields (3 fields). Each field must contain no spaces; multi-value fields use commas as the internal sub-separator.

- Field 1: `audit_name` — Name of the audit context
- Field 2: `email_destinations` — Comma-separated list of recipient email addresses
- Field 3: `cc_list` — Comma-separated list of CC email addresses, or `none` for no CC

**Example:**

```text
client1 john@example.com,jane@example.com manager@example.com
```

**Created by:** `gmake database_email_add audit=AUDIT_NAME dst=EMAILS cc=EMAILS`

### db_postaudit.txt

Stores post-audit request status for each audit context.

**Format:** Single field (1 field), one audit name per line

- Field 1: `audit_name` — Name of the audit context

**Example:**

```text
client1
client2
```

**Created by:** `gmake database_postaudit_add audit=AUDIT_NAME`

### db_info.txt

Stores metadata for all compiled tests including test names, purposes, descriptions, risk levels, and NIST 800-53 mappings (read-only, generated).

**Format:** Semicolon-separated fields (9 fields)

- Field 1: `audit` — Assessment context (`repo` or audit name)
- Field 2: `supplier` — Vendor/platform (e.g., `cisco-ios`, `juniper-junos`)
- Field 3: `test_name` — Unique test identifier
- Field 4: `purpose` — One-line purpose of the test
- Field 5: `description` — Detailed description of what the test checks
- Field 6: `actions` — Recommended remediation actions
- Field 7: `nist800-53_ref` — NIST 800-53 control reference (e.g., `cm-7(1) | configuration management`)
- Field 8: `risk_level` — Risk level of the test (`high`, `medium`, `low`, or `info`)
- Field 9: `authors` — Test authors

**Generated automatically by:** `gmake catalog_build`

### Managing Database Entries

`db_info.txt` is generated and **must not be edited manually**. The other three are editable through gmake targets (the `add`/`update`/`del` variants share the same parameters):

```bash
gmake database_sync_add audit=client1 dir=/conf/,/conf/backup/ \
      regexinventory=.*switch.* scope=/inventory/scope.txt \
      regexos=cisco-ios|cisco-xe regexpathexclude=_backup \
      regexinventoryexclude=none

gmake database_email_add audit=client1 dst=john@example.com,jane@example.com \
      cc=manager@example.com

gmake database_postaudit_add audit=client1
```

---

# Development Practices

The sections below define how to work safely and consistently on cawk: file modification protocol, code style, testing workflow, documentation requirements, pragmatic principles, git workflow, and the pre-commit vigilance checklist.

## File Modification Protocol

### Backup Creation

**Mandatory:** Before modifying ANY existing file, follow this workflow:

1. **Check** if a `.orig` backup already exists: `ls file.awk.orig`
2. **Create** the backup **only if it doesn't exist**: `cp file.awk file.awk.orig`
3. **Then** proceed with edits using the Edit tool

```bash
# Step 1: Check if backup exists
ls file.awk.orig  # Returns non-zero if not found

# Step 2: Create backup only if it doesn't exist
[ ! -f file.awk.orig ] && cp file.awk file.awk.orig

# Step 3: Now proceed with edits (via Edit tool or manual)
```

**Why this order matters:**

- Creating the backup **before** editing ensures you have a pristine original
- Checking first prevents overwriting a previous backup point
- This creates a clear audit trail of the original state

### Change Review & Validation

**Mandatory:** After every modification:

1. **Review the change** — verify no syntax errors, correct and clear logic, no unintended side effects, and that the code follows existing patterns in the file.
2. **Test the change** — run the appropriate target:
   - Template changes: `gmake tests_repo` or `gmake tests_run`
   - Build system changes: `gmake check_repo` or `gmake check_run`
   - Database changes: `gmake catalog_build`
   - **Makefile/support/*.mk recipe changes: check `ARG_MAX` before running** — `gmake -n <target> 2>/dev/null | awk '{print length, NR}' | sort -rn | head -3` and confirm the longest expanded line stays under 131072 bytes (Linux's per-argument `MAX_ARG_STRLEN` — `PAGE_SIZE * 32`). This is a *different, stricter* limit than the overall `getconf ARG_MAX` (~2MB): `/bin/sh -c "<recipe>"` passes the entire recipe as **one** argv string, so a single long line can fail with "Argument list too long" (exit 127) well before total `ARG_MAX` is reached. **Never write `$(foreach x,$(shell find ...), <recipe-line>)`** — Make expands this into one copy of `<recipe-line>` per match *before* the shell ever runs, so the line grows linearly with however many files/tests/suppliers exist (as of this writing, sequential test execution alone was already at ~70% of the limit with room for only ~170 more tests, and structurally could only grow). Use a **shell-level loop** instead — `find ... | while read -r x; do ...; done` — so the recipe text stays constant-size regardless of match count; this is what `cawk_test_execution` and its Makefile duplicates do. The same rule applies to any future `$(foreach ...,$(shell find/wildcard ...), ...)` pattern, and to per-iteration `|| $(ECHO) "..."` inside a loop: prefer logging to a file and reporting once after the loop over inline per-iteration messages. **Also watch plain `for x in $(SOME_LIST); do ...; done` loops** (no `foreach` involved): if `SOME_LIST` is a Make variable whose size is *unbounded* over the tool's lifetime — e.g. `RUN_DIRS`/`RUN_DIRS_FIND` (one entry per `create_audit` ever run, unlike `SUPPLIER_SCOPE` which is fixed at ~18) — Make still substitutes the whole list literally into the `for x in ...` line before the shell runs it, so the line grows with audit count even though the loop body is written once. Prefer `$(RUN_DIRS_FIND) | while read -r audit; do ...; done` (defined once in `support/Makefile.support.mk`, re-run fresh by the shell on each use) over `for dir in $(RUN_DIRS)`; when the loop also needs a "list is empty" message, count first with `count=$$($(RUN_DIRS_FIND) | wc -l); if [ "$$count" -eq 0 ]; then ...; else $(RUN_DIRS_FIND) | while read -r audit; do ...; done; fi` — do *not* try to set a flag variable inside the `| while read` body and test it afterward, since the pipe runs the loop in a subshell and any variable assigned inside it is lost once the pipe exits. A `for x in $(SUPPLIER_SCOPE)` or a shell glob bounded to the supplier list (`for f in $(EXCEPTION_PATH)/repo/*.m4`) is fine as-is — the risk is specifically lists that grow with audits/history, not ones bounded by the fixed supplier count.
3. **Document the change** — update `README.md` (if a feature/command/option changes) and `ChangeLog.md` (always, with a brief summary and date).

### Compiled vs Source Files: Critical Rule

**STRICT RULE: Never modify compiled `.gawk` files. Only modify source templates.**

The build system compiles source templates into `.gawk` files via `gmake`:

- `*.gawk.template` → `sed` substitution → `*.gawk`
- `*.gawk.m4` → `m4` preprocessing → `sed` → `*.gawk`
- `*.gawk.include` → `sed` substitution → `*.gawk`

Direct edits to `.gawk` files are **overwritten at the next build** — changes are lost when `gmake` rebuilds from templates.

**Correct workflow:**

```bash
# ✅ CORRECT
cp common/my_script.gawk.template common/my_script.gawk.template.orig
# Edit common/my_script.gawk.template
gmake tests_repo  # Recompiles to common/my_script.gawk

# ❌ WRONG — Changes will be lost at next build
# Edit common/my_script.gawk
gmake tests_repo  # Regenerates from template, losing edits
```

### Validation Checklist

```
[ ] Backup created (if file is new, skip this)
[ ] Code compiles without errors
[ ] Tests pass (relevant test suite)
[ ] Code follows project style (see Code Style & Consistency)
[ ] Comments added for non-obvious logic
[ ] README updated (if applicable)
[ ] ChangeLog updated
[ ] No unintended whitespace changes
```

## Code Style & Consistency

### Language

**Mandatory:** All code, comments, documentation, and commit messages use **English**. Internal variable/function names may reflect domain terms (e.g., `vendor_regex`, `conf_name`). Comments explain the WHY, not the WHAT.

### Comments

Use comments sparingly — add one **only if the logic is non-obvious**. Do NOT comment what the code obviously does; DO comment constraints, workarounds, and subtle invariants.

**Good comment:**
```awk
# Cisco commands may span multiple lines; skip until end-of-block marker
while (getline > 0 && $0 !~ /^!/) {
  # accumulate lines
}
```

**Bad comment:**
```awk
# Check if variable is set
if (var != "") { ... }  # ← The code already says this
```

### Naming Conventions

- **Function names:** `lower_snake_case` (e.g., `check_auth()`, `validate_config()`)
- **Variables:** `lower_snake_case` (e.g., `risk_level`, `vendor_name`, `test_name`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_DEPTH`, `CONFIG_PATH`)
- **Sed placeholders:** `%SED_UPPERCASE_PATTERN%` (e.g., `%SED_AUTHUSER_CISCO%`)
- **m4 macros:** `UPPER_CASE` (e.g., `BLOCK_INDENT`, `VENDOR_PATTERN`)

### Formatting

**AWK:**
```awk
function validate_risk(level) {
  if (level ~ /^(high|medium|low|info)$/) {
    return 1
  }
  return 0
}
```

**Make:** use TAB (not spaces) for recipe indentation.

**Sed (in support/tests.sed):** use clear delimiters, e.g. `s|%SED_GAWK_PATH%|/usr/bin/gawk|g`.

## Working with Tests

### Creating a New Test

See [Writing a New Test](#writing-a-new-test) above for the metadata tags and output format. In short: create the `*.gawk.template` source under `tests/repo/tests.<supplier>/`, add the required `# @tag : value` metadata and the `#!%SED_GAWK_PATH%` shebang + `@include "%SED_INCLUDE_PATH%"`, output via `print_err()`, then compile and validate:

```bash
gmake tests_repo          # Compile all repo tests
gmake check_repo          # Run integrity checks
gmake catalog_build       # Validate test metadata
```

### Modifying a Test

1. Create a `.orig` backup (if none exists)
2. Make changes carefully:
   - Preserve metadata comments exactly as needed
   - Test the regex patterns against known configs
   - Ensure backward compatibility (or document breaking changes in ChangeLog)
3. Recompile: `gmake tests_repo`
4. Run: `gmake check_repo` or `gmake clean check_run audit=<name>`
5. Update ChangeLog with a one-line summary

### PSIRT & Include Tests

- **PSIRT tests:** use `*.gawk.include` format; compiled with sed only
- **M4 block-parse tests:** use `*.gawk.m4` format; compiled with m4 then sed
- **Standard tests:** use `*.gawk.template` format; compiled with sed only

## Pragmatic Code Principles

### Simplicity & Clarity

- **Write clear code first.** Optimizations come later, if profiling shows they're needed.
- **Avoid premature abstraction.** Three similar lines don't need a helper function yet.
- **Trust internal guarantees.** Don't validate data that can't be invalid (trust frame/input contracts).
- **Validate only at boundaries.** External APIs, user input, file I/O — validate there. Internal function calls: assume the contract.

### Avoid Anti-Patterns

**Don't:**
- Add error handling for scenarios that can't happen
- Use feature flags or backward-compatibility shims when the code can just be changed
- Leave placeholder comments (e.g., `// TODO`, `// FIXME` without context) — if it's not done, either do it or remove the comment
- Rename unused variables to `_old_name` — if unused, delete it
- Leave "// removed" comments for deleted code — the history is in git

**Do:**
- Delete unused code completely
- Make breaking changes clearly (document in ChangeLog)
- Keep the code "as simple as possible, but no simpler" — match the complexity of the problem

### Pragmatic Testing

- For changes to AWK functions: run `gmake check_repo` or a targeted test suite
- For build system changes: verify with `gmake check_repo`
- For vendor-specific logic: test against that vendor's config samples
- For database changes: run `gmake catalog_build` to validate

## Documentation Requirements

### README.md

**Update if:** a command/target is added, an option/flag is added, a new supplier is supported, a major feature is documented in CLAUDE.md, or installation/setup steps change. Format: GitHub Flavored Markdown, clear structure, kept current.

### ChangeLog.md

**Group by technical area, not by change type.** Each version's entries are organized under topic headings — `Makefile`, `Tests`, `Database`, `Supplier`, `Docs`, `CI/CD`, `Build`, or another area name that fits — never under `Fixed`/`Added`/`Changed`. A given version uses only the headings its changes actually need; a version touching only tests and the Makefile has just those two sections. Put a change under the section matching *what it touches* (a Makefile recipe, a test file, a database script), not under whether it happened to fix a bug or add a feature — a section can (and usually does) freely mix fixes and additions.

**One line per entry, no exceptions.** Every bullet is a single line: `<Fix|Add|Rename|...> <what> <where>` — state the change, not the reasoning, the investigation, or the "why". Drop rationale, file-line counts, before/after code snippets, and multi-clause justifications; if the change needs more context than one line can hold, that context belongs in the commit message or PR description, not here. A single Markdown line may run long in raw characters — that's fine — but it must never wrap into a second bullet, a sub-bullet, or a colon-separated list block.

**Example (one version, several topic sections):**
```markdown
## [v4.1.0] - ... 2026

### Makefile

- Fix `check_run` swallowing a failed `sync_cawk_conf.gawk` call
- Add `clean_logs_repo`/`clean_logs_run` to `check_repo`/`check_run`

### Tests

- Add `acl_configconsistency_set.juniper-junos` (10th supplier)
- Fix `int_ipv6redirects_notset`: skip shutdown interfaces

### Database

- Add `db_sync.txt` field 7 `regexinventoryexclude`
```

## Git Workflow Details

Commits, pushes, and branch management are performed **only by the user**. Claude Code may inspect the working tree for review (`git status`, `git diff`) but must not modify git state.

**Claude Code will:**

1. ✅ Create `.orig` backups before modifying files
2. ✅ Review file changes (including via `git diff` / `git status`)
3. ✅ Update ChangeLog and README (if applicable)
4. ✅ Run tests to validate changes (`gmake check_repo`, etc.)
5. ✅ Provide a summary of file modifications for user review

**Claude Code will NOT:**

1. ❌ Create commits or push to remote
2. ❌ Create or switch branches
3. ❌ Run any other state-changing git command (`git add`, `git commit`, `git reset`, etc.)

### User Commit Steps

```bash
git status                 # 1. Check status
git diff                   # 2. Review diffs
ls *.orig                  # 3. Verify .orig backups exist for modified files
gmake check_repo           # 4. Run tests (or check_run audit=<name>)
git add <files>            # 5. Stage and commit
git commit -m "..."        #    Use the format below
git push origin <branch>
```

### Commit Message Format

```
<Category>: <Brief summary>

<Detailed explanation (if needed)>

Affected files:
- <path/to/file.ext>
```

**Categories:** Fix, Feature, Docs, Build, Refactor, Test, Chore

**Example:**
```
Fix: Correct CIS database missing IDs for control mappings

Add 7 missing CIS IDs to db_info.txt: 1.1, 2.2.3, 2.2.4, 2.2.5, 2.3.4, 2.3.5, 3.1.
These IDs are referenced in test metadata but were not in the database, breaking
catalog_build validation.

Affected files:
- database/db_info.txt
- ChangeLog.md
```

## Vigilance Checklist

Before the user pushes or merges, verify:

- [ ] **Backups created** — all modified files have `.orig` backups (new files: N/A)
- [ ] **Code reviewed** — logic correct, no syntax errors, no unintended side effects
- [ ] **Tests pass** — appropriate test suite runs without failures
- [ ] **Style consistent** — naming, formatting, and commenting conventions followed
- [ ] **English throughout** — no non-English code or comments
- [ ] **Documentation updated** — README.md, ChangeLog.md (if applicable)
- [ ] **No debug code** — no leftover debugging `print` / `print_err()`
- [ ] **Metadata correct** — test `@tags` match compiled filenames, all required fields present
