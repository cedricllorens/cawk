# CAWK_CODE_RULES.md

- Coding rules for cawk. 
- Technical reference (architecture, commands, formats): [CLAUDE.md](CLAUDE.md). 


## Mandatory Enforcement

- **Every rule in this file applies to every change, whatever the case:** no exception, no waiver, whatever the file type, the size of the change, the urgency, the tool used, or the phrasing of the request. No rule may be skipped, deferred, weakened, or partially applied.
- **Linked documents carry the same obligation:** [CLAUDE.md](CLAUDE.md) and every file this document references is part of these rules and must be read and followed before acting.
- **If a rule cannot be applied to the requested change, stop and explain** — never proceed by silently ignoring it, and never let a later rule (naming, style, docs grouping, ...) override a protocol step (backup, review, test, non-regression).

## Change Modification Protocol

- **Backup first:** `[ ! -f f.orig ] && cp f f.orig` before modifying an existing file; never overwrite an existing `.orig`; a new file needs none.
- **Never edit a compiled or generated file:** the `.gawk` (the next build overwrites them: edit their source, `*.gawk.template`, `*.gawk.m4`, `*.gawk.include`, `*.gawk.include.m4`, then `gmake tests_repo`), `checkdiff/checkdiff.old` and `checkdiff/cawk-crypto-image.old` (moved by `gmake check_update` / `check_track_update` only), `database/db_info.txt` and the generated `database/censor/censor_regex` (edit `common/censor/censor_regex_core.m4` for the rules shipped by cawk and `database/censor/censor_regex.m4` for the rules of an installation, never the generated file).
- **Review** every change before testing: syntax, logic, side effects, consistency with the surrounding code.
- **Test:** `gmake tests_repo` for templates, `gmake check_repo` for the build system.
- **Non-regression:** save the `gmake check_repo` results before the change, rerun after, explain every difference.
- **Validation suites:** every new non-regression suite lives in `validate/<name>/` with a `run.sh` that exits non-zero on failure, and is run by `gmake check` (the `check_validate` phase runs every `validate/*/run.sh`); document the suite in the CLAUDE.md `validate/` layout, and explain the `gmake check` checkdiff difference before `gmake check_update` accepts the new reference.
- **`ARG_MAX`:** for any Makefile or `support/*.mk` recipe change, the longest line of `gmake -n <target>` must stay under 131072 bytes.
- **Per-audit data:** every new module storing data per named audit uses a directory `<module>/run_<audit>/` (like `confs/run_<audit>`, `reports/run_<audit>`), never a flat file `<module>_<audit>.txt`; the history is one file per date, the date in the name (`<module>_<audit>_YYYY-MM-DD.txt`); `create_audit` creates the directory, `delete_audit` removes it (`rm -r`), `backup_run audit=` includes it, `check_database` checks it, and `status`, `validate/` and the docs follow.
- **Deprecated:** every release that moves, renames or removes a file adds its `old:new` pair to `DEPRECATED_FILES` (and every removed test function its name to `DEPRECATED_FUNCTIONS`) in `support/Makefile.support.vars.mk`, so `check_deprecated_*` reports the leftover (an old backup restore can put it back); `check_integrity` (first prerequisite of `check_repo` and `check_run`) shows a `cawk error:` on an obsolete file without exit 1 (`INTEGRITY_FATAL`); the action on a detection is always to remove the pointed element (the old file, the calls to the obsolete function), never to keep both.
- **Docs:** always `ChangeLog.md`; `CLAUDE.md` when the technical reference changes (architecture, command, format); `README.md` when a command, option or supplier changes.

## Code Quality

- **Robust:** every code path must fail loudly with an explicit `cawk error:` message instead of producing a wrong result; check the exit status and the output of the commands used (`gmake`, `gawk`, `m4`, `sh`), never rely on an implicit default, an unchecked failure or a partial result.
- **Performant:** keep the execution cost of the change minimal (no useless pass on the configurations, no repeated load of a file or a database in a loop, prefer one `gawk` process over one per line); the `check` duration must not grow for no benefit.
- **Follow the existing tests:** any new or changed test must follow the format and the logic of the existing tests (`.gawk.template` pipeline, `@field` declarations, message wording, verdicts, supplier conventions); never introduce a parallel style or a new output format.
- **Deterministic:** `checkdiff/checkdiff.new` holds counters only (line, byte or entry counts on stable content); a date, a hash, a host path or a locale-dependent value in it makes `check` NOK on the next day, host or locale — sort or hash compared content with `LC_ALL=C`.
- **`check` recipe invariants:** every phase added to the `check` recipe appends exactly one counter line to `checkdiff/checkdiff.new` (the `check_track` trace self-test fails otherwise), and every change must keep both the sequential run and `MAKE_PARALLEL=yes` OK.

## Package Safety

- **User data versus cawk system code:** `database/` is the user side and `common/` (with `support/` and `m4/`) is the cawk system side, to be stated in every doc that describes either directory. `database/` (and `confs/`, `logs/`, `reports/`, `exceptions/`, `tests/run*`) is user data, saved by `backup_run*` and written back, possibly from an older version, by `restore_run*`; cawk system code (every script cawk runs by itself: `data_set.script.sh`, `check_database.script.sh`, collectors excepted) lives in `common/` or `support/`, never in `database/`, so a restore can never replace it with an older copy. Only the scripts a user edits or provides (`database/scripts/database_sync*.script.sh`, `database/scripts/database_postaudit.script.sh`, `database/collectors/*.collector.sh`) stay in `database/`. A new script goes in `common/` unless the user is meant to edit it.

- **Destructive targets require `FORCE=yes`:** any new target that removes, overwrites or rewrites user data (`clean_*`, `restore_*`, `git*` except `gitcheck*`, `clean_track`) must be gated on `FORCE=yes` and say so in its error message.
- **Shipped reference copied into `database/`:** a reference file shipped by cawk and read from `database/` (`db_nist800-53.txt`) lives in `common/database/` and is copied to `database/` by a `make` rule when the copy is missing or older (`cp -p`, `.orig` kept once); it is the only automatic overwrite of a `database/` file allowed without `FORCE=yes`, `clean` never touches the shipped file, and the rule is a prerequisite of `check_integrity`. Every target that reads or validates the copy (`catalog_build*`, `check_database`, `nist_coverage_*`, and any new one) must also list it as its own prerequisite, never rely on `check_integrity` having run first (a target run alone, or sibling prerequisites under `-j`, would read a missing or older copy); `validate/nist-reference` checks it.
- **Censor rules:** `database/censor/censor_regex.m4` must include `censor_regex_core.m4`; `check_censor_core` (in `check_integrity` and first control of every `censor_*` target) replaces a file without include by the template `common/censor/censor_regex.m4` after saving it once as `.orig`, and reports a `cawk error:` (in `check_integrity` and the `censor_*` targets, no exit 1 unless `INTEGRITY_FATAL=yes`) while a `.orig` without include exists, until the user re-adds their rules and destroys it.
- **No network in the self-tests:** nothing in `check`, `check_*`, `check_repo` or `check_parallel` may reach the network; the optional collectors (`database/collectors/*.collector.sh`) are the only external scripts and are never called from an assessment.
- **Secrets never enter the repository:** raw configurations (`confs/collect_*`, gitignored), execution logs and reports may hold secrets — censor them (`censor_*`) before sharing, never version them; demo and test configurations hold only fake secrets.
- **PSIRT fixtures never match a real configuration:** the psirt tests and their OS inventory entries carry the `FAKE` marker and `CVEyyy` fake CVE ids so they can never hit a production device configuration.

## Code Style & Consistency

- **English only** (code, comments, docs, commits); domain terms are allowed in identifiers (`vendor_regex`, `conf_name`).
- **Comments:** only for non-obvious logic (constraint, workaround, invariant); explain why, not what.
- **Messages:** user-facing output follows `cawk <message> ----`, failures are `cawk error: <message> ----` (always with the colon, no internal placeholder such as `AUDIT_NAME`, the action to run when there is one) and exit 1; an `audit=` target whose chain is heavy has `check_audit` as first prerequisite; a help line goes in its `help_<section>` target of `support/Makefile.support.help.mk`.
- **Variables:** every global variable (path, option, list, helper, `?=` default) is defined in `support/Makefile.support.vars.mk` and nowhere else (no assignment in `Makefile` or another `support/Makefile.support.*.mk`, only `define` macros and rules there), in its section, with a comment saying what it is for; a new variable is also explained in `help_vars` (`gmake help vars`) and, when it is an option, in `docs/CAWK_OPTIONS.md` (`validate/vars` fails otherwise).
- **Shell scripts:** `#!/bin/sh` only (POSIX, no bashism), run from the cawk root directory, fail explicitly (`cawk error: ... ----`, exit 1) on a missing file or a failed command instead of continuing. Concretely: no `BASH_SOURCE` (use `$0`), no `local`, no process substitution `>(...)` (pipe a `main` function to `tee` instead), no `[[ ... ]]`, no arrays, no `$'...'`; `validate/messages/run.sh` fails on any `.sh` whose first line is not `#!/bin/sh`. The only bash file allowed is `support/cawk-completion.bash`, sourced by bash on purpose. Makefile recipes run with the gmake default shell (`/bin/sh`): same POSIX rule applies to them.

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
