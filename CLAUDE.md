# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Practices & Standards

For development guidelines, including backup protocol, code style, testing requirements, documentation updates, and vigilance checklist, refer to **[CLAUDE.CAWK-PRACTICES.md](CLAUDE.CAWK-PRACTICES.md)**.

This is the single source of truth for how to work safely and consistently on cawk. Key topics:

- File modification protocol (backups, review, validation)
- Code style (English, comments, naming conventions)
- Testing workflow (templates, compilation, validation)
- Documentation requirements (README, ChangeLog)
- Pragmatic principles (simplicity, trust contracts, no premature abstraction)
- Git workflow and commit message format
- Pre-commit vigilance checklist (10 points)

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
```

## Test Template Pipeline

Tests are **never written as `.gawk` directly**. They are authored as one of three source formats and compiled at build time:

| Source format | Compiled via | Use case |
|---|---|---|
| `*.gawk.template` | `sed` (support/tests.sed) | Standard tests |
| `*.gawk.m4` | `m4` then `sed` | Tests needing M4 block-parse macros |
| `*.gawk.include` | `sed` (PSIRT mode) | PSIRT vulnerability tests |

The build rule in `Makefile.support.mk` converts these to `*.gawk` files. The sed rules in `support/tests.sed` substitute vendor-specific placeholders (e.g., `%SED_GAWK_PATH%`, `%SED_AUTHUSER_CISCO%`) with system/vendor-specific values.

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

Tests and confs are organized per supplier. Current scope (defined in `Makefile.support.mk`):

`cisco-ios`, `cisco-xr`, `cisco-xe`, `cisco-cedge`, `cisco-viptela`, `juniper-junos`, `huawei-vrp`, `fortinet-fortios`, `nokia-sros`, `paloalto-panos`, `checkpoint-fwcli`, `packetfilter-fwcli`, `iptables-fwcli`, `6wind-linux`, `ekinops-oneos`

## Writing a New Test

1. Create `tests/repo/tests.<supplier>/<test_name>.<supplier>.gawk.template`
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

## Key Configuration: Makefile.support.mk

Global options that affect all assessments:
- `CAWK_RELEASE` — current version
- `MAKE_PARALLEL` / `MAKE_J` / `MAKE_FILES_PER_TARGET` — parallel execution
- `PSIRT` — enable PSIRT tests (`yes`/`no`)
- `DEADBEEF` / `DEADBEEF_THRESHOLD_DAYS` — flag configs older than N days
- `JSON` — generate JSON reports alongside text reports
- `ARCHIVE_OLDER_DAYS` — auto-cleanup of old report archives

All options can be overridden per-invocation: `gmake check_run audit=client1 PSIRT=yes DEADBEEF=yes`

## Assessment Types

- **repo** — runs against `tests/repo/` + `confs/repo/` — used for self-testing and demo
- **run** — runs against `tests/run/` + `confs/run/` — default working assessment
- **run_`<audit>`** — named audit with isolated tests/confs/exceptions/reports; created with `create_audit`

Named audits (`audit=AUDIT_NAME`) are the primary workflow for real network assessments.

## Database Format

cawk uses flat-file databases stored in the `database/` directory for managing audit-specific configurations and metadata.

### db_sync.txt

Stores configuration for automatic config synchronization across devices.

**Format:** Semicolon-separated fields (6 fields)

- Field 1: `audit_name` — Name of the audit context (matches `audit=AUDIT_NAME`)
- Field 2: `sync_paths` — Comma-separated list of remote paths to sync (e.g., `/conf/,/conf/backup/`)
- Field 3: `device_regex` — Extended regex pattern to match device names (e.g., `.*switch.*`)
- Field 4: `scope_file` — File path containing device inventory scope, or `none` for all devices
- Field 5: `os_regex` — Extended regex pattern to match OS types (e.g., `(cisco-ios|cisco-xe)`)
- Field 6: `path_exclude` — Extended regex pattern to exclude paths (e.g., `_backup`), or `none` for no exclusions

**Example:**

```text
client1;/conf/,/conf/cawk/;.*switch.*;/inventory/scope.txt;cisco-ios|cisco-xe;_backup
```

**Created by:** `gmake database_sync_add audit=AUDIT_NAME ...`

### db_email.txt

Stores email notification configuration for each audit context.

**Format:** Semicolon-separated fields (3 fields)

- Field 1: `audit_name` — Name of the audit context
- Field 2: `email_destinations` — Comma-separated list of recipient email addresses
- Field 3: `cc_list` — Comma-separated list of CC email addresses, or `none` for no CC

**Example:**

```text
client1;john@example.com,jane@example.com;manager@example.com
```

**Created by:** `gmake database_email_add audit=AUDIT_NAME dst=EMAILS cc=EMAILS`

### db_postaudit.txt

Stores post-audit request status for each audit context.

**Format:** Semicolon-separated field (1 field)

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
