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

See [Working with Tests](#working-with-tests) for the full workflow on creating, modifying, and validating tests.

## Key Configuration: Makefile.support.mk

Global options that affect all assessments:

| Option | Values | Default | Purpose |
|--------|--------|---------|---------|
| `CAWK_RELEASE` | version string | (varies) | Current cawk release version |
| `MAKE_PARALLEL` | `yes` / `no` | `no` | Spawn multiple make jobs for parallel test execution |
| `MAKE_J` / `MAKE_FILES_PER_TARGET` | number | 4 / 100 | Parallel job count and config files per target job |
| `PSIRT` | `yes` / `no` | `no` | Assessment mode: `no` = standard **plus** PSIRT tests; `yes` = PSIRT tests **only** (standard skipped). PSIRT tests are always compiled; this flag only selects which run. |
| `DEADBEEF` | `yes` / `no` | `no` | Flag configs older than threshold |
| `DEADBEEF_THRESHOLD_DAYS` | number | 30 | Days to consider a config "old" |
| `JSON` | `yes` / `no` | `no` | Generate JSON reports alongside text |
| `CATALOG_BUILD` | `yes` / `no` | `no` | Rebuild test catalog (db_info.txt) before assessment |
| `ARCHIVE_OLDER_DAYS` | number | 120 | Auto-cleanup of old report archives |

All options can be overridden per-invocation:

```bash
gmake check_run audit=client1 PSIRT=yes JSON=yes DEADBEEF_THRESHOLD_DAYS=180
```

## Makefile Gotchas & Conventions

Hard-won lessons when editing the Makefile — verify against these before changing recipe logic:

- **`check_repo` and `check_run` bodies are duplicated ~12×** (across the supplier × parallel × audit branches). The tail is factored into the `cawk_report_tail` canned recipe, but the collection/exception/summary blocks are copy-pasted and **drift easily**. When you change one branch, mirror the change across all matching branches, and diff `repo` vs `run` variants to keep them aligned.
- **`$(findstring x,LIST)` matches substrings, not words.** For membership validation (e.g. `supplier=`), use `$(filter x,LIST)` which compares whole space-separated words. `findstring` wrongly accepted partial names like `cisco`, `ios`, `juni`.
- **`ECHO = echo` has no `-e`.** Do not rely on `\n` inside `$(ECHO) "...\n..."` — interpretation depends on the shell (`dash` expands, `bash` doesn't). Use one `$(ECHO)` per line instead.
- **`exit 0` in an error branch masks the failure** — the recipe (and any prerequisite like `check_supplier`) reports success, so callers/CI can't detect it and assessments silently produce empty reports. Use `exit 1` for genuine user errors.
- **`PSIRT` is an assessment *mode*, not an enable flag** — see the options table. PSIRT `.gawk` are always compiled; `PSIRT=yes` runs them *exclusively*.
- **Quoted shell globs don't expand**: `[ -d "$(TESTS_PATH)/run_*" ]` is always false (literal `run_*`). Prefer an unguarded `find $(TESTS_PATH)/run_* ... 2>/dev/null || true`, matching the style already used elsewhere in `clean`.
- **Anchor audit-name matching.** `sed`/`grep` on an audit name must be anchored (trailing space for space-separated DBs, `$` for one-name-per-line), otherwise `client1` also matches `client1_backup` / `client10`. Likewise avoid `run_${audit}*` globs in backup/delete recipes.
- **`archive_repo` archives into `reports/repo/archives/`** (not `run/`); keep the `tar` destination and the echoed path in sync.

## Assessment Types

- **repo** — runs against `tests/repo/` + `confs/repo/` — used for self-testing and demo
- **run** — runs against `tests/run/` + `confs/run/` — default working assessment
- **run_`<audit>`** — named audit with isolated tests/confs/exceptions/reports; created with `create_audit`

Named audits (`audit=AUDIT_NAME`) are the primary workflow for real network assessments.

## Database Format

cawk uses flat-file databases stored in the `database/` directory for managing audit-specific configurations and metadata.

### db_sync.txt

Stores configuration for automatic config synchronization across devices.

**Format:** Space-separated fields (6 fields). Each field must contain no spaces; multi-value fields use commas as the internal sub-separator.

- Field 1: `audit_name` — Name of the audit context (matches `audit=AUDIT_NAME`)
- Field 2: `sync_paths` — Comma-separated list of remote paths to sync (e.g., `/conf/,/conf/backup/`)
- Field 3: `device_regex` — Extended regex pattern to match device names (e.g., `.*switch.*`)
- Field 4: `scope_file` — File path containing device inventory scope, or `none` for all devices
- Field 5: `os_regex` — Extended regex pattern to match OS types (e.g., `(cisco-ios|cisco-xe)`)
- Field 6: `path_exclude` — Extended regex pattern to exclude paths (e.g., `_backup`), or `none` for no exclusions

**Example:**

```text
client1 /conf/,/conf/cawk/ .*switch.* /inventory/scope.txt cisco-ios|cisco-xe _backup
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
      regex=.*switch.* scope=/inventory/scope.txt \
      regexos=cisco-ios|cisco-xe regexpathexclude=_backup

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

**Always update with:**
- **Date** in ISO format (YYYY-MM-DD)
- **Category** (e.g., `Fix`, `Feature`, `Docs`, `Build`)
- **Description** (1-2 lines, what changed and why)
- **Affected scope** (which files, targets, suppliers)

**Example:**
```markdown
### Fixed
- **2026-05-09** — Fix CIS database: add missing CIS IDs 1.1, 2.2.3-5 to db_info.txt ([db_info.txt](database/db_info.txt))

### Added
- **2026-05-07** — Add CIS benchmark references to error stats section in report output
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
