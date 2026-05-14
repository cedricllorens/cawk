# CAWK Code Practices Guide

This document consolidates the core practices, principles, and guidelines for working with the cawk codebase. All contributors must follow these standards to maintain code quality, consistency, and maintainability.

## Overview: The Three Core Tools

cawk relies exclusively on:
- **gawk** (GNU AWK) — test execution engine
- **gmake** (GNU Make) — build system and task runner
- **m4** (GNU M4) — macro expansion for test templates

All build and execution commands use `gmake`, never plain `make`.

---

## 1. File Modification Protocol

### 1.1 Backup Creation

**Mandatory:** Before modifying ANY existing file, follow this workflow:

1. **Check** if a `.orig` backup already exists: `ls file.awk.orig`
2. **Create** the backup **only if it doesn't exist**: `cp file.awk file.awk.orig`
3. **Then** proceed with edits using Edit tool

**Correct workflow:**

```bash
# Step 1: Check if backup exists
ls file.awk.orig  # Returns 2 if not found, 0 if exists

# Step 2: Create backup only if it doesn't exist
[ ! -f file.awk.orig ] && cp file.awk file.awk.orig

# Step 3: Now proceed with edits (via Edit tool or manual)
```

**Why this order matters:**

- Creating backup **before** editing ensures you have a pristine original
- Checking first prevents overwriting previous backup points
- This creates a clear audit trail of what the original state was

**Rationale:** Backups allow reverting to the original state if something goes wrong. Preserving existing backups prevents accidental loss of previous recovery points from earlier changes.

### 1.2 Change Review & Validation

**Mandatory:** After every modification:

1. **Review the change** — Use `/simplify` or manual review to verify:
   - No syntax errors
   - Logic is correct and clear
   - No unintended side effects
   - Code follows existing patterns in the file

2. **Test the change** — Run appropriate tests:
   - For template changes: `gmake tests_repo` or `gmake tests_run`
   - For build system changes: `gmake check_repo` or `gmake check_run`
   - For database changes: `gmake catalog_build` to validate

3. **Document the change** — Update:
   - `README.md` — if feature/command/option changes
   - `ChangeLog.md` — always, with brief summary of change and date

### 1.3 Validation Checklist

```
[ ] Backup created (if file is new, skip this)
[ ] Code compiles without errors
[ ] Tests pass (relevant test suite)
[ ] Code follows project style (see section 2)
[ ] Comments added for non-obvious logic
[ ] README updated (if applicable)
[ ] ChangeLog updated
[ ] No unintended whitespace changes
```

---

## 2. Code Style & Consistency

### 2.1 Language

**Mandatory:** All code, comments, documentation, and commit messages use **English**.

Exceptions:
- Internal variable/function names may reflect domain terms (e.g., `vendor_regex`, `conf_name`)
- Comments explain the WHY, not the WHAT

### 2.2 Comments

**Use Comments Sparingly:**
- Add a comment **only if the logic is non-obvious**
- Do NOT comment what the code obviously does
- DO comment the WHY: constraints, workarounds, subtle invariants

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

# Loop through fields
for (i = 1; i <= NF; i++) { ... }  # ← Obviously loops through fields
```

### 2.3 Naming Conventions

- **Function names:** `lower_snake_case` (e.g., `check_auth()`, `validate_config()`)
- **Variables:** `lower_snake_case` (e.g., `risk_level`, `vendor_name`, `test_name`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_DEPTH`, `CONFIG_PATH`)
- **Sed placeholders:** `%SED_UPPERCASE_PATTERN%` (e.g., `%SED_AUTHUSER_CISCO%`)
- **m4 macros:** `UPPER_CASE` (e.g., `BLOCK_INDENT`, `VENDOR_PATTERN`)

### 2.4 Formatting

**AWK:**
```awk
function validate_risk(level) {
  if (level ~ /^(high|medium|low|info)$/) {
    return 1
  }
  return 0
}
```

**Make:**
```makefile
# Proper indentation: use TAB, not spaces
target: prerequisite
	command --flag value
	another_command
```

**Sed (in support/tests.sed):**
```bash
# Substitutions use clear delimiters
s|%SED_GAWK_PATH%|/usr/bin/gawk|g
s|%SED_AUTHUSER_CISCO%|privileged|g
```

---

## 3. Working with Tests

### 3.1 Creating a New Test

1. Create the source file in the correct location:
   ```
   tests/repo/tests.<supplier>/<test_name>.<supplier>.gawk.template
   ```

2. Include required metadata comments (with `#` prefix, `@tag : value` format):
   ```awk
   # @test_name : my_test_name
   # @supplier : cisco-ios
   # @purpose : Check for weak encryption algorithms
   # @description : Detects use of DES, RC4, or MD5 in cryptographic operations
   # @risk_level : high | medium
   # @actions : Replace weak algorithms with AES-256, SHA-256, or stronger
   # @nist800-53_ref : SC-13 | Cryptographic Protection
   # @authors : John Doe, Jane Smith
   ```

3. Use the correct include paths and shebang:
   ```awk
   #!%SED_GAWK_PATH%
   
   @include "%SED_INCLUDE_PATH%"
   ```

4. Output results using `print_err()` with format:
   ```
   conf_name|test_name|error_line|line_number|risk_level|status_code
   ```
   - Valid status codes: `pass`, `error`, `warning`, `psirt`

5. Compile and validate:
   ```bash
   gmake tests_repo          # Compile all repo tests
   gmake check_repo          # Run integrity checks
   gmake catalog_build       # Validate test metadata
   ```

### 3.2 Modifying a Test

1. Create `.orig` backup (if none exists)
2. Make changes carefully:
   - Preserve metadata comments exactly as needed
   - Test the regex patterns against known configs
   - Ensure backward compatibility (or document breaking changes in ChangeLog)
3. Recompile: `gmake tests_repo`
4. Run: `gmake check_repo` or `gmake clean check_run audit=<name>`
5. Update ChangeLog with a one-line summary

### 3.3 PSIRT & Include Tests

- **PSIRT tests:** Use `*.gawk.include` format; compiled with sed only
- **M4 block-parse tests:** Use `*.gawk.m4` format; compiled with m4 then sed
- **Standard tests:** Use `*.gawk.template` format; compiled with sed only

---

## 4. Build System & Makefile

### 4.1 Common Commands

```bash
# Show all available targets
gmake

# Show version
gmake version

# Check integrity (run first after install)
gmake check

# Full demo assessment (repo tests + demo configs)
gmake clean check_repo view_repo

# Create a named audit
gmake create_audit audit=client1

# Run assessment for a named audit
gmake clean check_run view_run audit=client1

# Run for specific supplier
gmake check_run view_run audit=client1 supplier=cisco-ios

# Compile tests only (no assessment)
gmake tests_repo

# Clean all generated files
gmake clean
```

### 4.2 Configuration: Makefile.support.mk

Global options affecting all assessments:

| Option | Values | Default | Purpose |
|--------|--------|---------|---------|
| `CAWK_RELEASE` | version string | (varies) | Current cawk release version |
| `PSIRT` | `yes` / `no` | `yes` | Enable PSIRT vulnerability tests |
| `DEADBEEF` | `yes` / `no` | `no` | Flag configs older than threshold |
| `DEADBEEF_THRESHOLD_DAYS` | number | 365 | Days to consider config "old" |
| `JSON` | `yes` / `no` | `no` | Generate JSON reports alongside text |
| `ARCHIVE_OLDER_DAYS` | number | 30 | Auto-cleanup old report archives |

**Override per invocation:**
```bash
gmake check_run audit=client1 PSIRT=yes JSON=yes DEADBEEF_THRESHOLD_DAYS=180
```

---

## 5. Database Management

### 5.1 db_info.txt (Generated, Read-Only)

Auto-generated by `gmake catalog_build`. Do NOT edit manually.

**Fields (9):**
1. `audit` — context (repo or audit name)
2. `supplier` — vendor/platform
3. `test_name` — unique identifier
4. `purpose` — one-line summary
5. `description` — detailed explanation
6. `actions` — remediation steps
7. `nist800-53_ref` — compliance reference
8. `risk_level` — high/medium/low/info
9. `authors` — contributor names

**Example:**
```
repo;cisco-ios;weak_crypto;Detect weak encryption;Finds DES, RC4, MD5 use;Replace with AES-256;SC-13|Cryptographic Protection;high;John Doe
```

### 5.2 db_sync.txt, db_email.txt, db_postaudit.txt

**Editable** via gmake targets. Format: semicolon-separated fields.

**Create entries:**
```bash
gmake database_sync_add audit=client1 paths="/conf/,/conf/backup/" \
      device_regex=".*switch.*" scope_file="/inventory/scope.txt" \
      os_regex="cisco-ios|cisco-xe" path_exclude="_backup"

gmake database_email_add audit=client1 dst="john@example.com,jane@example.com" \
      cc="manager@example.com"

gmake database_postaudit_add audit=client1
```

---

## 6. Pragmatic Code Principles

### 6.1 Simplicity & Clarity

- **Write clear code first.** Optimizations come later, if profiling shows they're needed.
- **Avoid premature abstraction.** Three similar lines don't need a helper function yet.
- **Trust internal guarantees.** Don't validate data that can't be invalid (trust frame/input contracts).
- **Validate only at boundaries.** External APIs, user input, file I/O — validate there. Internal function calls: assume the contract.

### 6.2 Avoid Anti-Patterns

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

### 6.3 Pragmatic Testing

- For changes to AWK functions: run `gmake check_repo` or targeted test suite
- For build system changes: verify with `gmake check_repo`
- For vendor-specific logic: test against that vendor's config samples
- For database changes: run `gmake catalog_build` to validate

---

## 7. Documentation Requirements

### 7.1 README.md

**Update if:**
- New command/target added to Makefile
- New option/flag added
- New supplier supported
- New major feature documented in CLAUDE.md
- Installation/setup steps change

**Format:** GitHub Flavored Markdown, clear structure, keep current

### 7.2 ChangeLog.md

**Always update with:**
- **Date** in ISO format (YYYY-MM-DD)
- **Category** (e.g., `Fix`, `Feature`, `Docs`, `Build`)
- **Description** (1-2 lines, what changed and why)
- **Affected scope** (which files, targets, suppliers)

**Example:**
```markdown
## [Unreleased]

### Fixed
- **2026-05-09** — Fix CIS database: add missing CIS IDs 1.1, 2.2.3-5 to db_info.txt ([db_info.txt](database/db_info.txt))
- **2026-05-08** — Correct @test_name metadata in 45 tests to match compiled .gawk filenames ([tests/repo/](tests/repo/))

### Added
- **2026-05-07** — Add CIS benchmark references to error stats section in report output

### Changed
- **2026-05-06** — Change database separator from pipe (|) to semicolon (;) to prevent CSV parsing issues ([database/](database/))
```

---

## 8. Git Workflow

⚠️ **IMPORTANT:** Claude Code must NOT create git commits. All git operations (commits, pushes, branch management) must be done manually by the user. Claude Code responsibility ends at code changes and documentation updates.

### 8.1 Claude Code Responsibilities (Before User Commits)

Claude Code will:

1. ✅ Create `.orig` backups before modifying files
2. ✅ Review changes with `git diff` and `git status` output
3. ✅ Update ChangeLog and README (if applicable)
4. ✅ Run tests to validate changes
5. ✅ Provide summary of changes for user review

Claude Code will NOT:

1. ❌ Create git commits
2. ❌ Push to remote
3. ❌ Create or switch branches
4. ❌ Perform any git operations

### 8.2 User Responsibilities (Manual Commits)

The user will perform all git operations:

```bash
# 1. Check status
git status

# 2. Review diffs
git diff

# 3. Verify .orig backups were created for modified files
ls *.orig

# 4. Run tests (optional, if not done by Claude Code)
gmake check_repo        # or gmake check_run audit=<name>

# 5. Review ChangeLog and README updates
cat ChangeLog | head -20
```

Then create the commit:

```bash
git add <files>
git commit -m "..."  # Use format below
git push origin <branch>
```

### 8.3 Commit Message Format

```
<Category>: <Brief summary>

<Detailed explanation (if needed)>

Affected files:
- <path/to/file.ext>
- <path/to/other.ext>
```

**Categories:** Fix, Feature, Docs, Build, Refactor, Test, Chore

**Example:**
```
Fix: Correct CIS database missing IDs for control mappings

Add 7 missing CIS IDs to db_info.txt: 1.1, 2.2.3, 2.2.4, 2.2.5, 2.3.4, 2.3.5, 3.1.
These IDs are referenced in test metadata but were not in the database, breaking
catalog_build validation. Regenerated db_info.txt with 100% CIS coverage.

Affected files:
- database/db_info.txt (145 lines updated)
- ChangeLog.md (entry added)
```

---

## 9. Vigilance Checklist

Before pushing or merging, verify:

- [ ] **Backups created** — All modified files have `.orig` backups (if new files, N/A)
- [ ] **Code reviewed** — Logic is correct, no syntax errors, no unintended side effects
- [ ] **Tests pass** — Appropriate test suite runs without failures
- [ ] **Style consistent** — Follows naming, formatting, and commenting conventions
- [ ] **English throughout** — No non-English code or comments
- [ ] **Documentation updated** — README.md, ChangeLog.md (if applicable)
- [ ] **Commit message clear** — Explains what changed and why
- [ ] **No debug code** — No `print`, `print_err()` for debugging left in
- [ ] **Metadata correct** — Test @tags match compiled filenames, all required fields present

---

## 10. Quick Reference: Common Tasks

### Adding a Test
```bash
# 1. Create file
touch tests/repo/tests.cisco-ios/my_test.cisco-ios.gawk.template

# 2. Add header, metadata, logic
# 3. Create backup (if modifying existing)
# 4. Compile and check
gmake tests_repo
gmake check_repo

# 5. Update ChangeLog, commit
```

### Modifying Build Configuration
```bash
# 1. Edit Makefile.support.mk
cp Makefile.support.mk Makefile.support.mk.orig  # (if needed)

# 2. Test the change
gmake check_repo

# 3. Update ChangeLog, commit
```

### Creating a Named Audit
```bash
gmake create_audit audit=client1
gmake check_run view_run audit=client1
gmake list_audit
```

### Running Assessment with Options
```bash
gmake clean check_run view_run audit=client1 \
  supplier=cisco-ios PSIRT=yes JSON=yes
```

---

## Summary

The cawk project succeeds through:
1. **Discipline** — Follow the file modification protocol, backup, test, review
2. **Clarity** — Write code that is obvious, document the WHY not the WHAT
3. **Consistency** — Use English, follow naming/style conventions, use the right tools
4. **Documentation** — Keep README, ChangeLog, and code comments accurate and current
5. **Pragmatism** — Write simple code first, trust contracts, don't over-engineer

Questions? Refer to [CLAUDE.md](CLAUDE.md) for technical details or review git history for examples.
