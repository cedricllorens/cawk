# Makefile ↔ Makefile.support.mk Consistency Audit

## Architecture

```
Makefile (94 targets, 108 ifeq blocks)
├── include Makefile.support.mk (line 10)
│   ├── Variables (46 defined)
│   ├── Pattern Rules (4 %.xxx rules)
│   └── Supplier templates (forEach loops)
└── .PHONY: (line 22, recently reformatted)
```

✓ **Include placement is correct** — comes at line 10, before .PHONY (line 22)

---

## ✓ GOOD: No Critical Issues Found

- ✓ No duplicate targets (0 targets defined in both files)
- ✓ No circular dependencies
- ✓ No variables used before definition
- ✓ No conflicts between variable names and target names
- ✓ No file shadowing (no files named catalog_build, tests_run, etc. exist)
- ✓ All support/ files referenced exist (support/tests.sed, m4/, etc.)

---

## ⚠️ MEDIUM: Design Decision to Verify

### Pattern Rules — Three %.gawk Rules
**Location:** Makefile.support.mk lines 43, 47, 56

```makefile
%.gawk: %.gawk.template    # Line 43 — processes *.template files
%.gawk: %.gawk.include     # Line 47 — processes *.include files  
%.gawk: %.gawk.m4          # Line 56 — processes *.m4 files
```

**Current behavior:**
- These are mutually exclusive in practice (no file has both .template and .include extensions)
- If a future file *did* have both, line 43 (template) would win, hiding line 47 (include)

**Why this works:** Each source directory (tests.cisco-ios, tests.juniper-junos, etc.) contains either:
- `*.gawk.template` files (standard tests), OR
- `*.gawk.m4` files (block-parse tests), OR
- `*.gawk.include` files (PSIRT tests)

Never mixed.

**Recommendation:** Document this design, or add defensive checks to catch if a file somehow gets two extensions (could be added to CI/linting).

---

## MEDIUM: Missing .PHONY in Makefile.support.mk

**Issue:** 0 targets in support.mk are declared as .PHONY, even though they're not file-producing.

**Pattern rules affected:**
- `%.gawk: %.gawk.template` — .gawk is produced, OK
- `%.script: %.script.sh` — .script is produced, OK
- `%: %.m4` — produces file with same base name, OK

**Actually fine:** Pattern rules that produce files don't need .PHONY (they're file targets). Only targets that don't produce files need .PHONY.

**Status:** No action needed (pattern rules are correctly file-producing).

---

## Information: Variable Distribution

### In Makefile.support.mk (46 variables):
```
Paths:        CONFS_PATH, BACKUP_PATH, DATABASE_PATH, LOGS_PATH, 
              TESTS_PATH, TESTS_COMMON_PATH, EXCEPTION_PATH, REPORT_PATH

Dynamic:      RUN_DIRS (computed from filesystem)
Suppliers:    SUPPLIER_SCOPE, SUPPLIER_M4_REPO_FILES, TESTS_*_*_PATH, etc.
Config:       ARCHIVE_OLDER_DAYS, CATALOG_BUILD, DEADBEEF, DEADBEEF_THRESHOLD_DAYS,
              JSON, MAKE_PARALLEL, MAKE_J, MAKE_LOAD_AVG, PSIRT
Tools:        RM, ECHO, EGREP
```

### In Makefile (108 ifeq blocks + 94 targets):
- All variables from support.mk are **available** after line 10 include
- Conditional logic uses `$(audit)` (user input, not predefined)
- Heavy use of `RUN_DIRS` (discovered dynamically from filesystem)

---

## GOOD: Conditional Variable Handling

**Pattern observed:**
```makefile
some_target:
ifeq ($(strip $(audit)),)
  @# No audit specified → use /run paths
  gmake sub_target
else
  @# audit specified → use /run_$(audit) paths
  gmake sub_target audit=$(audit)
endif
```

✓ Properly handles both default and named-audit workflows
✓ Consistent throughout (108 ifeq blocks = 54 target families with audit branching)

---

## Summary: Cross-File Consistency Status

| Aspect | Status | Finding |
|--------|--------|---------|
| Targets | ✓ | 94 in Makefile, 0 in support.mk (intentional division) |
| Variables | ✓ | 46 in support.mk used throughout Makefile |
| Pattern rules | ✓ | 4 rules, mutually exclusive in practice |
| Dependencies | ✓ | No circular; include at correct location |
| Conditionals | ✓ | Proper audit/default branching (108 ifeq blocks) |
| .PHONY | ⚠️ | 22 missing from Makefile (FIXED), 0 in support.mk (OK) |

**Coherence Score: 9/10** — Excellent separation of concerns (targets in Makefile, rules/vars in support.mk).

---

## Files

- `Makefile` — 94 targets, .PHONY recently reformatted (6 per line)
- `Makefile.support.mk` — 46 variables, 4 pattern rules, 3 conditional blocks
- `support/tests.sed` — sed substitution rules (referenced by pattern rules)
- `m4/cawk.m4` — M4 macros for block-parse templates
