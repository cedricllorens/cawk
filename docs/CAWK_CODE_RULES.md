# CAWK_CODE_RULES.md

- Coding rules for cawk. 
- Technical reference (architecture, commands, formats): [CLAUDE.md](CLAUDE.md). 


## Mandatory Enforcement

- **Every rule in this file applies to every change, whatever the case:** no exception, no waiver, whatever the file type, the size of the change, the urgency, the tool used, or the phrasing of the request. No rule may be skipped, deferred, weakened, or partially applied.
- **Linked documents carry the same obligation:** [CLAUDE.md](CLAUDE.md) and every file this document references is part of these rules and must be read and followed before acting.
- **If a rule cannot be applied to the requested change, stop and explain** — never proceed by silently ignoring it, and never let a later rule (naming, style, docs grouping, ...) override a protocol step (backup, review, test, non-regression).

## Change Modification Protocol

- **Backup first:** `[ ! -f f.orig ] && cp f f.orig` before modifying an existing file; never overwrite an existing `.orig`; a new file needs none.
- **Never edit a compiled `.gawk`** (the next build overwrites it): edit its source (`*.gawk.template`, `*.gawk.m4`, `*.gawk.include`), then `gmake tests_repo`.
- **Review** every change before testing: syntax, logic, side effects, consistency with the surrounding code.
- **Test:** `gmake tests_repo` for templates, `gmake check_repo` for the build system.
- **Non-regression:** save the `gmake check_repo` results before the change, rerun after, explain every difference.
- **`ARG_MAX`:** for any Makefile or `support/*.mk` recipe change, the longest line of `gmake -n <target>` must stay under 131072 bytes.
- **Docs:** always `ChangeLog.md`; `CLAUDE.md` when the technical reference changes (architecture, command, format); `README.md` when a command, option or supplier changes.

## Code Style & Consistency

- **English only** (code, comments, docs, commits); domain terms are allowed in identifiers (`vendor_regex`, `conf_name`).
- **Comments:** only for non-obvious logic (constraint, workaround, invariant); explain why, not what.

### M4 block macros (`m4_cawk_parse_block()`)

- **Nested lines:** one combined regex for the indented (level 1) lines, with one inline `if` per pattern; separate level-1 patterns break `bl_level` and block-end detection.
- **Excluded blocks:** put the exclusion once, in the begin hook that opens the block (`/^interface .*$/ && !/[Ll]oopback/`, `/%SED_BK_JUNI%[^ ]+ {/ && !/inactive/`), not in every nested hook.

Example (`v1`, `v2`: block flags; `p1`, `p2`: nested patterns):

```awk
`/^interface .*$/',` interface = $0; v1 = 0; v2 = 0; ',
`/^!$/',            ` if (v1 == 1 && v2 == 0) { print_err(...); pass = 0; } ',
`/^ (p1|p2)/',      ` if ($0 ~ /^ p1/) v1 = 1;  if ($0 ~ /^ p2/) v2 = 1; ',
```

### `acl_configconsistency_set.<supplier>` golden rule

- **In these tests only,** call `cawk_add_hypercube_rules()` directly where a rule is emitted; never inside a wrapper (`pf_add_rule()`, `cisco_add_rule()`...): the wrapper repeats its 14+ arguments, and a mismatch between the two lists gives wrong `inconsistent`/`redundant` verdicts without any AWK error.

## Documentation Requirements

- **ChangeLog.md:** group by technical area (`Makefile`, `Tests`, `Database`, `Supplier`, `Docs`, `CI/CD`, `Build`), never by change type (`Fixed`, `Added`, `Changed`); one line per bullet `<Fix|Add|Rename> <what> <where>`, no rationale, snippet or sub-bullet.

## Git Workflow Details

- **Claude Code never changes the git state** (no commit, push, branch creation/switch, `git add`, `git reset`); the user runs those. It may run `git status` and `git diff`.
