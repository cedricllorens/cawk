# Makefile Consistency Audit — Revised (2026-04-19)

## Executive Summary
**Critical: 1** | **High: 2** | **Medium: 4**

---

## CRITICAL BUG

### Bug #1: 22 Targets Defined But Missing from .PHONY
**Severity: CRITICAL**

These targets are defined in Makefile but **NOT declared as .PHONY**:

```
catalog_build                check_analyze              check_checkdiff
check_debug                  check_debug_log            check_parallel_debug
exceptions_run_audit_copy    exceptions_run_copy        nist_coverage_official
nist_coverage_repo           nist_coverage_run          postaudit_run
postaudit_run_audit          sync_psirt                 tests_check_nok
tests_common                 tests_repo                 tests_run
tests_run_audit              tests_target_common        tests_target_repo
tests_target_run
```

**Why this matters:**
- If any file named `tests_run`, `catalog_build`, `postaudit_run_audit` etc. exists in repo root, `make` treats it as a file dependency, not a target
- Target won't rebuild if source files change (misses newer timestamps)
- **Non-deterministic behavior**: same command succeeds on some systems, skipped on others

**Test case:**
```bash
touch tests_run              # Create file named tests_run
gmake tests_run              # Will do nothing instead of running target!
gmake --always-make tests_run # Forces rebuild
```

**Fix:** Add all 22 targets to `.PHONY:` declaration on line 22 of Makefile.

---

## HIGH PRIORITY

### Issue #2: Incomplete Triplet Patterns (repo/run/run_audit)

14 target families have **incomplete variants**:

| Base | _repo | _run | _run_audit | Issue |
|------|-------|------|-----------|-------|
| `archive` | ✓ | ✓ | ✗ | **Missing:** `archive_run_audit` |
| `catalog` | ✓ | ✓ | ✗ | **Missing:** `catalog_run_audit` |
| `catalog_build` | ✓ | ✓ | ✗ | **Missing:** `catalog_build_run_audit` |
| `catalog_exceptions` | ✓ | ✓ | ✗ | **Missing:** `catalog_exceptions_run_audit` |
| `exceptions` | ✓ | ✓ | ✗ | **Missing:** `exceptions_run_audit` |
| `exceptions_build` | ✓ | ✓ | ✗ | **Missing:** `exceptions_build_run_audit` |
| `nist_coverage` | ✓ | ✓ | ✗ | **Missing:** `nist_coverage_run_audit` |
| `tests_target` | ✓ | ✓ | ✗ | **Missing:** `tests_target_run_audit` |
| `view` | ✓ | ✓ | ✗ | **Missing:** `view_run_audit` |
| `backup` | ✗ | ✓ | ✓ | **Missing:** `backup_repo` (intentional?) |
| `postaudit` | ✗ | ✓ | ✓ | **Missing:** `postaudit_repo` (intentional?) |
| `restore` | ✗ | ✓ | ✓ | **Missing:** `restore_repo` (intentional?) |
| `sync` | ✗ | ✓ | ✓ | **Missing:** `sync_repo` (intentional?) |
| `sync_teststoconfs` | ✗ | ✓ | ✓ | **Missing:** `sync_teststoconfs_repo` (intentional?) |

**Inconsistency:** Most targets have _repo ✓ _run ✓ _run_audit ✗, but 5 targets are missing _repo entirely.

**Impact:** Users cannot run named audits for catalog/archive/exceptions operations:
- ✓ Works: `gmake catalog_build_run audit=client1`
- ✗ Fails: `gmake catalog_build_run_audit` (no target found)

---

### Issue #3: Plain Targets Mixed with Pattern Families

Some targets have both _repo/_run/_run_audit variants AND a plain version:
- `check` (has check_repo, check_run, check_run_audit, **and** check)
- `catalog_build` (has catalog_build_repo, catalog_build_run, **and** catalog_build)
- `exceptions_build` (has exceptions_build_repo, exceptions_build_run, **and** exceptions_build)

**Question:** Are the plain versions (`catalog_build`, `exceptions_build`) intended as helpers, or are they conflicting definitions?

---

## MEDIUM PRIORITY

### Issue #4: .PHONY Line 22 Is Unreadable
72 targets in single line, no grouping. Recomm organized by function:

```makefile
.PHONY: all version system common help \
  check check_repo check_run check_run_audit \
  catalog_repo catalog_run catalog_exceptions_repo catalog_exceptions_run \
  tests_repo tests_run tests_run_audit_copy \
  exceptions_repo exceptions_run exceptions_build_repo ...
```

### Issue #5: Ambiguous Target Naming
Inconsistent patterns make it unclear which targets are generic vs. function-specific:
- Generic: `all`, `version`, `check`, `migrate`, `system`, `common`, `supplier`
- Database ops: `database_view`, `database_sync_add`, `database_email_add` (no suffix pattern)
- Email ops: `email_send`, `email_send_audit` (mixed)
- Sync ops: `sync_psirt`, `sync_run`, `sync_run_audit` (mixed)

### Issue #6: Makefile.support.mk Has No .PHONY
Makefile.support.mk contains 94 targets + pattern rules but zero `.PHONY` declarations. Pattern rules are OK but explicit guards help.

### Issue #7: Variables Used Without Explicit Declaration in Some Targets
Some targets reference `$(audit)` and conditionally use it, but `audit` is not a formal variable—it's optional user input. This is implicit and hard to trace.

---

## Summary Table: Fixes Required

| Issue | Count | Type | Fix |
|-------|-------|------|-----|
| Missing .PHONY declaration | 22 | CRITICAL | Add to line 22 |
| Missing _run_audit variants | 9 | HIGH | Create 9 new targets |
| Missing _repo variants | 5 | HIGH | Investigate intent (backup, postaudit, etc.) |
| Conflicting plain targets | 3 | MEDIUM | Clarify purpose of `catalog_build`, `exceptions_build` |
| .PHONY readability | 1 | MEDIUM | Reformat with grouping |
| Naming ambiguity | ~10 | MEDIUM | Document pattern choices |

---

## Recommended Fixes (Prioritized)

### Phase 1: Fix Critical .PHONY Bug (5 min)
```makefile
# Line 22: Add these 22 targets
.PHONY: ... catalog_build check_analyze check_checkdiff check_debug \
  check_debug_log check_parallel_debug exceptions_run_audit_copy exceptions_run_copy \
  nist_coverage_official nist_coverage_repo nist_coverage_run postaudit_run \
  postaudit_run_audit sync_psirt tests_check_nok tests_common tests_repo tests_run \
  tests_run_audit tests_target_common tests_target_repo tests_target_run
```

### Phase 2: Add Missing _run_audit Targets (20 min)
Create 9 targets:
- `archive_run_audit` → loop over `$(RUN_DIRS)` and call `archive_run`
- `catalog_run_audit`, `catalog_build_run_audit`, `catalog_exceptions_run_audit`
- `exceptions_run_audit`, `exceptions_build_run_audit`
- `nist_coverage_run_audit`, `tests_target_run_audit`, `view_run_audit`

**Pattern:** Similar to `check_run_audit` and `backup_run_audit`

### Phase 3: Investigate Missing _repo Targets (10 min)
Check if `backup_repo`, `postaudit_repo`, `restore_repo`, `sync_repo`, `sync_teststoconfs_repo` are intentionally repo-less or oversight.

---

## Testing Commands

```bash
# Verify no file shadows targets
ls -la | grep -E "catalog_build|tests_run|postaudit_run"

# Verify all .PHONY targets exist
make -n archive_run_audit 2>&1 | head -5

# Force rebuild (workaround for file shadowing)
gmake --always-make tests_run
```

---

## Files Requiring Changes

- `Makefile` line 22 — Add 22 missing .PHONY targets
- `Makefile` lines 600-900 — Add 9 missing `*_run_audit` targets
- `Makefile.support.mk` — (Optional) Add `.PHONY` guards for internal targets
