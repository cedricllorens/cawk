# cawk database formats

Reference split from [CLAUDE.md](../CLAUDE.md).

## Database Format

cawk uses flat-file databases stored in the `database/` directory for managing audit-specific configurations and metadata.

**`database/` is the user side, `common/` is the cawk system side.** `database/` holds the data and the rules of the installation (databases, `data_set/`, `sync_scopes/`, `censor/censor_regex.m4`, `scripts/database_*.script.sh`, `scripts/update_custom.script.sh` (your own script run by `gmake update_custom_run FORCE=yes` after a cawk update, empty by default, edited by the user), `collectors/`): saved by `backup_run*`, restored by `restore_run*`, never rewritten by a new cawk version. `common/` holds the code and the reference files shipped by cawk (`*.script.sh`, `censor/censor_regex_core.m4`, `database/db_nist800-53.txt`): never saved nor restored, replaced by every update, not to be edited. Two files go from `common/` to `database/` and are handled by `check_integrity`: `db_nist800-53.txt` (copied when missing or older, `.orig` kept once) and the template `common/censor/censor_regex.m4` (copied to `database/censor/censor_regex.m4` when that file lacks the include of the core, previous file kept in `.orig`).

### db_sync.txt

Stores configuration for automatic config synchronization across devices.

**Format:** Space-separated fields (7 fields). Each field must contain no spaces; multi-value fields use commas as the internal sub-separator.

- Field 1: `audit_name` — Name of the audit context (matches `audit=AUDIT_NAME`)
- Field 2: `sync_paths` — Comma-separated list of remote paths to sync (e.g., `/conf/,/conf/backup/`)
- Field 3: `inventory_regex` — Extended regex pattern a `scope_file` line (field 4) must match to be kept as an allowed device. **Only applied when `scope_file` is set** — if `scope_file` is `none`, this field has no effect and every file found under `sync_paths` is synced (see [`sync_cawk_conf.gawk.template`](common/sync_cawk_conf.gawk.template))
- Field 4: `scope_file` — File path containing device inventory scope (one entry per line; only the first whitespace-separated column is used as the device path), or `none` for all devices. The path is relative to the cawk root (an absolute path is rejected by the sync). `create_audit` sets it to `database/sync_scopes/<audit>_inventory_sync_scope.txt` and creates that file empty; an empty file (blank lines and `#` comments ignored) is no scope, every device is synced; a file that does not exist makes `sync_run` fail with `cawk error: scope file ... not found ----`; `database_sync_add`/`update` create an empty file for a new scope path; `delete_audit` removes the default file
- Field 5: `os_regex` — Extended regex pattern to match OS types (e.g., `(cisco-ios|cisco-xe)`)
- Field 6: `path_exclude` — Extended regex pattern to exclude paths (e.g., `_backup`), or `none` for no exclusions
- Field 7: `inventory_regex_exclude` — Extended regex pattern a `scope_file` line must **not** match to be kept, or `none` for no exclusion. Same "only applies with `scope_file`" restriction as field 3

**Example:**

```text
client1 /conf/,/conf/cawk/ .*switch.* database/sync_scopes/client1_inventory_sync_scope.txt cisco-ios|cisco-xe _backup none
```

**Created by:** `gmake database_sync_add audit=AUDIT_NAME ...`

**Viewed by:** `gmake database_view_sync` (also `database_view`), one block per audit (a `- - - -` separator before each), one `sync_paths` entry per line. The view never fails on an incomplete line: a missing field is shown with its default value and `(default)` (`.*` for regexinventory and regexos, `none` for the others), a missing `sync_paths` is shown `(missing, required)`, extra fields give a `cawk warning:`; the same rule applies to `database_view_collect` (`args` none, `collector` required), `database_view_email` (`cc_emails` none, `dst_emails` required) and `database_view_postaudit`. The strict format check stays `gmake check_database`:

```text
- - - - - - - - - - - - - - - - - - - - - -
audit                 : client1
sync_paths            : /conf/
                        /conf/cawk/
regexinventory        : .*switch.*
scope                 : database/sync_scopes/client1_inventory_sync_scope.txt
regexos               : cisco-ios|cisco-xe
regexpathexclude      : _backup
regexinventoryexclude : none
```

### db_collect.txt

Stores the optional config collector of each audit context (the link with the sync is the `sync_paths` field of `db_sync.txt`).

**Format:** Space-separated fields (3 fields), no space inside a field.

- Field 1: `audit_name` — Name of the audit context
- Field 2: `collector` — Collector name, the script `database/collectors/<collector>.collector.sh` (`scp`, `rsync`, `local`)
- Field 3: `args` — Collector arguments, comma-separated `key=value` pairs (no space, no comma in a value), or `none`: `scp` takes `host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=][,port=][,timeout=][,hostkey=yes|accept-new][,options=OPTS]` (`options` = extra scp/rsync options, words separated by `+`), `rsync` the same; both fetch one file per device from one central unix/linux system, the copy being automatic (`scp -rp` / `rsync -rt` over ssh, nothing to write); `local` takes `source_path=LOCAL_DIR` (absolute directory of the cawk machine) and copies one file per device with `cp -p`, no network

**Example:**

```text
client1 rsync host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519
client2 local source_path=/srv/confs/
```

**Default entry:** `create_audit` adds `<audit> none none` (collector `none` = no collection, skipped by `collect_run`, replaced by `database_collect_add`/`update`), `delete_audit` removes it with `confs/collect_<audit>` and the collect scope file.

**Contract of a collector:** called from the repository root as `sh database/collectors/<name>.collector.sh AUDIT DEST_DIR ARGS` (`DEST_DIR` = `confs/collect_<audit>`), it writes one plain-text file per device named after the device (no other write under `confs/`), exits `0` (all collected), `1` (a device failed: its previous file is kept) or `2` (usage/dependency error). Shared helpers in `database/collectors/collector_common.sh` (atomic non-empty write keeping the modification time, pruning of vanished devices only after a fully successful run). The sync reaches the files through `sync_paths` = `../collect_<audit>/` (`database_collect_sync` or `sync=yes` adds it, `collect_run` warns when it is missing): relative paths are resolved from `confs/run_<audit>`.

**Created by:** `gmake database_collect_add audit=AUDIT_NAME collector=NAME args=ARGS [sync=yes]` (`database_collect_update`, `database_collect_del`, `database_view_collect`)

**Viewed by:** `gmake database_view_collect` (also `database_view`), one block per audit, one `args` pair per line:

```text
audit     : client1
collector : rsync
args      : host=192.0.2.10
            user=cawk
            remote_path=/srv/confs/
```

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

**Viewed by:** `gmake database_view_email` (also `database_view`), one block per audit, one address per line:

```text
audit      : client1
dst_emails : john@example.com
             jane@example.com
cc_emails  : manager@example.com
```

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

**Viewed by:** `gmake database_view_postaudit` (also `database_view`), one `audit : AUDIT_NAME` block per line.

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

### db_exception.txt

Stores the exception rules of every audit context (read-only, generated from the `exceptions/*/*.m4` sources).

**Format:** Semicolon-separated fields (6 fields), header `audit;supplier;exception_id;approver;date;reason`

- Field 1: `audit` — Assessment context (`repo` or audit name)
- Field 2: `supplier` — Vendor/platform (e.g., `cisco-ios`, `juniper-junos`)
- Field 3: `exception_id` — Exception identifier (e.g., `exc-001`)
- Field 4: `approver` — Person who approved the exception
- Field 5: `date` — Approval date (`yyyy-mm-dd`)
- Field 6: `reason` — Business context of the exception

**Example:**

```text
audit;supplier;exception_id;approver;date;reason
repo;6wind-linux;exc-001;name;yyyy-mm-dd;brief business context
```

**Generated automatically by:** `gmake exceptions_build`

### db_nist800-53.txt

Reference list of the NIST 800-53 controls the tests map to. The file shipped by cawk is `common/database/db_nist800-53.txt` (never saved nor restored); `database/db_nist800-53.txt` is its working copy, created when missing and replaced (previous copy kept once in `.orig`) when older than the shipped file, by `check_integrity` (first control of `check_repo` and `check_run`). A copy edited later than the shipped file is kept.

**Format:** Semicolon-separated fields (4 fields), header `nist_id;category;description;applicable_suppliers`

- Field 1: `nist_id` — Control id in uppercase, `AC-2` or `AC-2(1)` (unique)
- Field 2: `category` — Control family (e.g., `Access Control`)
- Field 3: `description` — What the control requires
- Field 4: `applicable_suppliers` — `all` or the suppliers concerned

**Example:**

```text
nist_id;category;description;applicable_suppliers
AC-2;Access Control;Ensure account management is implemented;all
```

### censor_regex

Regexes used by `common/censor.gawk`, generated (`%: %.m4` rule) from two independent files — the **core rules shipped by cawk** `common/censor/censor_regex_core.m4` (replaced by every new version, never saved nor restored, do not edit) and **the rules of the installation** `database/censor/censor_regex.m4` (the only file to edit to control the censor module: it includes the core with `include(`censor_regex_core.m4')dnl`, then holds your own rules, saved and restored with `database/` and never rewritten by cawk). The include line is mandatory. When `check_integrity` (first control of `check_repo` and `check_run`) finds a `database/censor/censor_regex.m4` without it (a file restored from an older backup, an install from before the core), it saves the file once as `censor_regex.m4.orig` and replaces it by the template `common/censor/censor_regex.m4`; while a `.orig` without include exists the integrity phase stops with `cawk error: ... ----` (exit 1) until you copy your own rules after the include and destroy the `.orig` (`rm database/censor/censor_regex.m4.orig`), so a rule of yours can never be dropped without notice. Never edit the generated `censor_regex` (overwritten at the next `censor_*`).

**Format:** one macro of `m4/cawk_censor.m4` per line, not nested, the argument is a quoted gawk extended regex (must not match an empty string). The generated file is gawk code (`censor_apply()`, one statement per macro, applied in order, the regexes are regex constants so a regex must not contain an unescaped `/`: write `[/]`) `@include`d by `common/censor.gawk`; the text matched by the group 1 is kept, the rest of the match is replaced by the word (`CENSORED` by default).

- `censor_after(`regex')` — censors the text following the regex (nothing after it: line untouched)
- `censor_match(`regex')` — censors the text matched by the regex, so the regex must cover the value
- `censor_line(`regex')` — censors the whole line containing a match of the regex
- `censor_ignore(`regex')` — like `censor_match`, the case is ignored (letters inside a bracket expression are kept as written)
- every macro except `censor_ignore` takes an optional second argument `lowercaseuppercase` that ignores the case of the regex
- every macro takes an optional third argument, the distribution level `internal` (default) or `external` (`censor_ignore(`regex', `', `external')`: its second argument is unused). The generated `censor_regex` guards the `external` statements with `if (external)`; `common/censor.gawk` applies the `internal` ones always and the `external` ones only when `CENSOR_LEVEL=external` (set by `gmake censor_* CENSOR_LEVEL=external`, `internal` by default)

The default sections of `common/censor/censor_regex_core.m4` hold **one regex per section**, line by line, merging the syntaxes of every supplier: ADMIN, AUTHENTICATION, CRYPTO, SECRET, MONITORING, CERTIFICATE (`internal`) and IDENTITY, TOPOLOGY (`external`). After any change run `validate/censor/run.sh` (add the secret and a benign line of the new syntax to `validate/censor/cases.tsv`): the keywords of the SECRET alternatives must follow a space, an unindented keyword is not matched. Every added alternative costs time (`censor_repo` on the demo confs: 12 s with dynamic regexes, 1.9 s with the generated regex constants: gawk recompiles a dynamic regex at every line once more than 6 are in use).

**Example:**

```text
censor_after(`password')
censor_match(`secret +[^ ]+')
censor_ignore(`community +[^ ]+')
```

`confs.<supplier>.censored`, `logs/<context>.censored` and `reports/<context>.censored` directories are generated (rebuilt at each run) and ignored by `catalog_*` and `gitcheck`.

`common/censor.gawk` with `CENSOR_CSV=yes` (used by `SECRETSCAN=yes`) censors cawk csv reports: only the error_line (fields 3 to NF-3, it may hold `;`) goes through `censor_apply()`, `X.csv` is written into `X.censored.csv`.

`common/censor.gawk` runs in two modes: `censor` (default) writes the censored copy into `CENSOR_OUT_DIR` (one output file per input file, same name) or into the single file `CENSOR_OUT_FILE` (`gmake censor_file in= out=`, `gmake censor_stdout in=`), and `check` (`CENSOR_MODE=check`, `gmake censor_check in=`) writes nothing and exits 1 when a line would still be censored — the guard run before sharing a file or a censored directory.

### Managing Database Entries

`db_info.txt` is generated and **must not be edited manually**. The other three are editable through gmake targets (the `add`/`update`/`del` variants share the same parameters):

```bash
gmake database_sync_add audit=client1 dir=/conf/,/conf/backup/ \
      regexinventory=.*switch.* scope=database/sync_scopes/client1_inventory_sync_scope.txt \
      regexos=cisco-ios|cisco-xe regexpathexclude=_backup \
      regexinventoryexclude=none

gmake database_email_add audit=client1 dst=john@example.com,jane@example.com \
      cc=manager@example.com

gmake database_postaudit_add audit=client1
```

### Format Check

`gmake check_database` (also a phase of `gmake check`, right after `catalog_build` and `exceptions_build`) checks one by one every `.txt` database above — `db_sync.txt`, `db_collect.txt`, `db_email.txt`, `db_postaudit.txt`, `db_exception.txt`, `db_info.txt`, `db_nist800-53.txt`, and `psirt_scopes/psirt_os_inventory_scope.txt` (optional, checked when present) — against the format of this document and prints one explicit error per bad line:

- field count and headers, empty fields, duplicate entries (audit, test, control, device)
- `db_sync`: validity of the extended regexes, existence of the `scope_file`
- `db_collect`: collector in `none | scp | rsync | local`, its script present, `args` keys valid, required and not duplicated per collector
- `db_email`: every address of `dst` and `cc` matches the official RFC 5322 format (quoted local parts and comments are not expressible in a flat-file field)
- `db_exception`, `db_info`, `db_nist800-53.txt`: supported supplier, `yyyy-mm-dd` date, `.gawk` test name, `nist_id` control id, `high | medium | low | info` risk levels
- every database: referenced audits exist (`repo`, `run`, `run_AUDIT_NAME`), LF-only line endings

The check is implemented in `common/check_database.script.sh` (one gawk pass per database) and exits 1 when a database holds at least one bad line.


### data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt

Evolution of a named audit: one file per date (directory `database/data_set/run_<audit>/`, like `confs/run_<audit>`; the date is in the file name), each holding a header and one line of key values of the last assessment, read from `reports/run_<audit>/assessment.all.summary.txt` (counters only, no secret). It feeds the "Evolution of the audit" section of the html report, the only report that provides the evolution (`assessment.all.summary.txt` and `.json` hold the counters of the last assessment only) (compliance score, Pass / Errors, High/Medium/Low errors, Errors/Devices per date, not affected by the filters). Not versioned (`.gitignore`); included by `backup_run audit=`, restored by `restore_run`.

**Format:** each file holds a header line, then one line `date;key=value;key=value;...`; a second run the same day replaces the file of the day. Only the `DATA_SET_KEEP` last files (dates) are kept. `check_database` rejects a file whose name is not `data_set_<audit>_YYYY-MM-DD.txt`, whose directory is not `run_<audit>`, or whose line date differs from the name.

- `date` (YYYY-MM-DD)
- one `key=value` per counter of the "assessment stats" block of the summary, named without the `number_of_` prefix (`confs`, `confs_deadbeef`, `confs_badformat`, `confs_crlf`, `checks`, `checks_exceptions`, `pass`, `nist_pass`, `pass_exceptions`, `pass_high|medium|low|info`, the same for `error`, `warning` and `psirt`, `psirt_clear`, ...)
- `nist_ref_coverage=covered/total` and one `nist_<family>=covered/total` per NIST family of the summary
- no indicator and no percentage is stored: every one of the summary (`security_compliance`, `error_avg_perdevice`, `error_high_ratio`, `security_info_compliance`, the NIST coverages, the percentages) is exactly computed from these counters with the formulas of `common/report.gawk.template`
- required keys (`check_database`): `confs`, `checks`, `pass`, `error`, `warning`, `psirt`, `pass_*`, `error_*` (high, medium, low, info), `nist_ref_coverage`

**Example:**

```text
# date;key=value;... (keys: the number_of_* of the summary without the prefix, nist_ref_coverage=covered/total, nist_<family>=covered/total)
2026-11-06;confs=65;confs_deadbeef=0;confs_badformat=0;confs_crlf=0;checks=7304;checks_exceptions=4;pass=4118;pass_high=1043;pass_medium=2144;pass_low=8;pass_info=923;error=2014;error_high=716;error_medium=150;error_low=8;error_info=1140;warning=1042;psirt=0;nist_ref_coverage=27/118;nist_access_control=9/31
```

(truncated for the example: the real line holds every counter of the block.)

**Managed by:** `gmake create_audit` (creates the directory `run_<audit>`), `gmake check_run audit=AUDIT_NAME` (writes the file of the day, `DATA_SET=no` to skip, not with `supplier=`) and `gmake delete_audit` (removes the directory); the html report of the audit shows the evolution. No dedicated target. Checked by `gmake check_database` and `validate/data_set`.
