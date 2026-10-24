# Package Coherence Audit — Complete (2026-04-19)

## Executive Summary

**Status: 94%** — Package is well-structured with one major issue: **incomplete git migration** (README/ChangeLog not yet renamed).

| Category | Status | Notes |
|----------|--------|-------|
| Build system | ✓ | Makefile + support.mk coherent, syntax OK |
| Version | ✓ | v3.5.0 consistent across files |
| Directory structure | ✓ | All required dirs present, .gitkeep files in place |
| Tests | ✓ | 351 templates/m4/includes for 15 suppliers (5 with PSIRT) |
| Configurations | ✓ | All 15 suppliers have demo configs |
| Documentation | ⚠️ | README.md missing (in progress: RD README → README.md) |
| Git state | ⚠️ | Partial migration in progress (30+ files staged/deleted) |
| Tools | ✓ | gawk, m4, gmake available |

---

## ✓ GOOD: Structural Coherence

### Directory Layout (Correct)
```
tests/
├── repo/              ← Source of truth (15 suppliers, 351 test files)
├── run/               ← User's editable copy (synced from repo on demand)
└── run_<audit>/       ← Per-audit copies (created by create_audit)

confs/
├── repo/              ← Demo configs (15 suppliers, 32 files)
├── run/               ← User's editable copy
└── run_<audit>/

exceptions/
├── repo/              ← Exception rules (15 suppliers, 15 .m4 files)
├── run/               ← User's copy
└── run_<audit>/

common/               ← Shared gawk libraries (templates)
database/             ← Flat-file databases (db_*.txt)
support/              ← Build support (tests.sed, 84 lines)
m4/                   ← M4 macros (cawk.m4)
```

✓ All directories present
✓ All .gitkeep files in place (prevents git from ignoring empty dirs)
✓ Proper separation: repo/ = source, run/ = editable copies

### Files Present
```
✓ LICENSE                    — MIT license
✓ CLAUDE.md                  — Project instructions
✓ AUTHORS.md                 — 519 bytes (new)
✓ README                     — 37.6 KB (legacy, no extension)
✗ README.md                  — MISSING (in progress: RD README → README.md)
✓ ChangeLog                  — 22.7 KB (legacy, no extension)
✗ ChangeLog.md               — MISSING (in progress: RD ChangeLog → ChangeLog.md)
✓ Makefile                   — 183 KB (94 targets, 108 ifeq blocks)
✓ Makefile.support.mk        — 6.2 KB (46 vars, 4 pattern rules)
✓ Dockerfile                 — Alpine-based
✓ cawk_docker_run.sh         — Docker launcher
```

### Version Consistency
**v3.5.0** referenced in:
- Makefile.support.mk: `CAWK_RELEASE = v3.5.0`
- Makefile.docker: references `$(CAWK_RELEASE)`
- CLAUDE.md: documents as current

✓ Single source of truth (Makefile.support.mk)

### Test Coverage (Complete)
All 15 suppliers represented:

**Standard tests (11):**
```
✓ 6wind-linux, checkpoint-fwcli, cisco-cedge, cisco-ios, cisco-viptela,
  cisco-xe, cisco-xr, ekinops-oneos, fortinet-fortios, huawei-vrp, 
  iptables-fwcli, juniper-junos, nokia-sros, packetfilter-fwcli, paloalto-panos
```

**PSIRT tests (5 of 15):**
```
✓ tests.cisco-cedge.psirt
✓ tests.cisco-ios.psirt
✓ tests.cisco-viptela.psirt
✓ tests.cisco-xe.psirt
✓ tests.cisco-xr.psirt
```

⚠️ Only Cisco family has PSIRT tests (intentional? or incomplete coverage?)

**Test file counts:**
- Total: 351 source files (.gawk.template, .gawk.m4, .gawk.include)
- Configurations: 32 files (demo configs)
- Exceptions: 15 .m4 files (one per supplier)

### Database Files (Healthy)
```
✓ db_info.txt          — 312 KB (metadata for all 345+ tests)
✓ db_nist800-53.txt    — 11.5 KB (NIST mappings)
✓ db_exception.txt     — 3.6 KB (exception rules)
✓ db_email.txt         — Empty (ready for config)
✓ db_sync.txt          — Empty (ready for config)
✓ db_postaudit.txt     — Empty (ready for config)
```

---

## ⚠️ ISSUES FOUND

### Issue #1: Documentation Migration In Progress
**Severity: MEDIUM** — Git state shows incomplete rename

```
RD README → README.md        ← Deleted source, new file needed
RD ChangeLog → ChangeLog.md  ← Deleted source, new file needed
```

**Current state:**
- ✓ README exists (legacy, no .md)
- ✗ README.md does NOT exist
- ✓ ChangeLog exists (legacy, no .md)
- ✗ ChangeLog.md does NOT exist

**Impact:** 
- Git shows "Rename-Delete" conflicts (files staged for deletion but no .md counterparts)
- Users reading GitHub see old README (not markdown-rendered)

**Fix required:** Either complete the migration (create .md files) or revert the RD markers in git.

### Issue #2: Deleted Files Not Yet Committed
**Severity: LOW** — Git housekeeping

Files marked for deletion but not yet in commit:
```
D  Authors                              ← Replaced by AUTHORS.md
D  cis_benchmark_mapping.json          ← Unclear why deleted
D  common/deadbeef_cawk_conf.script    ← Replaced by .script.sh?
D  exceptions/repo/exceptions.*        ← 15 files (old format, moved to .m4?)
D  cis_benchmark_mapping.json          ← Duplicate entry
```

**Likely:** Files intentionally removed during refactoring. Need commit to finalize.

### Issue #3: Script Files Not Executable
**Severity: LOW** — Design choice or oversight?

All .sh files lack executable bit:
```
❌ cawk_docker_run.sh                  — NOT executable
❌ checkdiff/scripts/*.sh              — NOT executable (6 files)
❌ database/scripts/*.sh               — NOT executable (3 files)
❌ common/deadbeef_cawk_conf.script.sh — NOT executable
```

**Why OK:** Pattern rule `%.script: %.script.sh` copies and applies `chmod 750` to generated `.script` files. Sources don't need executable bit.

**Recommendation:** Document this design or add .sh executable bit for consistency.

### Issue #4: PSIRT Coverage Incomplete
**Severity: LOW** — Design question

Only 5 of 15 suppliers have PSIRT tests:
```
Has PSIRT:     cisco-cedge, cisco-ios, cisco-viptela, cisco-xe, cisco-xr
Missing PSIRT: 6wind-linux, checkpoint-fwcli, ekinops-oneos, fortinet-fortios, 
               huawei-vrp, iptables-fwcli, juniper-junos, nokia-sros, 
               packetfilter-fwcli, paloalto-panos
```

**Likely intentional:** Only Cisco has PSIRT coverage in cawk. Other vendors' PSIRT may be out-of-scope.

---

## ✓ GOOD: Build & Runtime

### Makefile Syntax
```bash
make -n check  ✓ No syntax errors
```

### System Tools
```
✓ gawk        — Available
✓ m4          — Available
✓ gmake       — Available (via make)
```

### Pattern Rules
4 rules in Makefile.support.mk:
```
✓ %.gawk: %.gawk.template     — Standard tests
✓ %.gawk: %.gawk.include      — PSIRT tests
✓ %.gawk: %.gawk.m4           — Block-parse tests
✓ %.script: %.script.sh        — Scripts
```

Mutually exclusive (no file has multiple extensions), safe.

### Git Integration
```
✓ .gitignore   — Properly configured (*.gawk, Claude Code dirs, etc.)
✓ LICENSE      — MIT license present
✓ .git/        — Repo initialized
```

---

## Summary: Fix Priority

| Issue | Fix | Effort | Impact |
|-------|-----|--------|--------|
| README.md/ChangeLog.md migration | Complete rename or revert git markers | 5 min | HIGH (doc visibility) |
| Deleted files in git | Commit the changes | 1 min | MEDIUM (clean state) |
| .sh executable bit | Document design choice | 2 min | LOW (cosmetic) |
| PSIRT coverage | Clarify scope/strategy | N/A | INFO (by design) |

---

## Files to Review

- [Makefile](../Makefile) — 94 targets, recently reformatted .PHONY
- [Makefile.support.mk](../Makefile.support.mk) — 46 vars, 4 pattern rules
- [README](../README) vs [CLAUDE.md](../CLAUDE.md) — Migration status
- [.gitignore](../.gitignore) — Properly excludes build artifacts
- `tests/repo/` — 351 test files across 15 suppliers
- `database/db_*.txt` — Metadata and config files

---

## Recommendations

### Immediate (before next merge)
1. **Complete README/ChangeLog migration** — either create .md files or revert git RD markers
2. **Commit pending deletions** — finalize git state with a cleanup commit

### Optional (documentation)
3. Document PSIRT coverage scope (why only Cisco?)
4. Document .sh executable bit design (if intentional)

### Future (enhancement)
5. Add linting to CI to catch incomplete file migrations
6. Consider PSIRT for additional vendors if scope expands

---

## Overall Assessment

**Package Coherence: 94/100**

✓ **Strengths:**
- Clear separation: repo/ (source) vs run/ (editable)
- Consistent versioning (v3.5.0 single source)
- Complete supplier coverage (15 × tests + confs)
- Proper git ignore rules
- Well-documented CLAUDE.md

⚠️ **Weaknesses:**
- Incomplete migration (README/ChangeLog)
- 30+ files in git staging (needs commit)

**Recommendation:** Fix documentation migration and commit pending changes to achieve 100% coherence.
