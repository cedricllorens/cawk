# cawk database formats

Reference split from [CLAUDE.md](../CLAUDE.md).

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

### censor_regex

Regexes used by `common/censor.gawk`, generated (`%: %.m4` rule) from `database/censor/censor_regex.m4` — **`censor_regex.m4` is the only file to edit to control the censor module**, never the generated `censor_regex` (overwritten at the next `censor_*`).

**Format:** one macro of `m4/cawk_censor.m4` per line, not nested, the argument is a quoted gawk extended regex (must not match an empty string). The generated file is gawk code (`censor_apply()`, one statement per macro, applied in order, the regexes are regex constants so a regex must not contain an unescaped `/`: write `[/]`) `@include`d by `common/censor.gawk`; the text matched by the group 1 is kept, the rest of the match is replaced by the word (`CENSORED` by default).

- `censor_after(`regex')` — censors the text following the regex (nothing after it: line untouched)
- `censor_match(`regex')` — censors the text matched by the regex, so the regex must cover the value
- `censor_line(`regex')` — censors the whole line containing a match of the regex
- `censor_ignore(`regex')` — like `censor_match`, the case is ignored (letters inside a bracket expression are kept as written)
- every macro except `censor_ignore` takes an optional second argument `lowercaseuppercase` that ignores the case of the regex
- every macro takes an optional third argument, the distribution level `internal` (default) or `external` (`censor_ignore(`regex', `', `external')`: its second argument is unused). The generated `censor_regex` guards the `external` statements with `if (external)`; `common/censor.gawk` applies the `internal` ones always and the `external` ones only when `CENSOR_LEVEL=external` (set by `gmake censor_* CENSOR_LEVEL=external`, `internal` by default)

The default sections of `censor_regex.m4` hold **one regex per section**, line by line, merging the syntaxes of every supplier: ADMIN, AUTHENTICATION, CRYPTO, SECRET, MONITORING, CERTIFICATE (`internal`) and IDENTITY, TOPOLOGY (`external`). After any change run `validate/censor/run.sh` (add the secret and a benign line of the new syntax to `validate/censor/cases.tsv`): the keywords of the SECRET alternatives must follow a space, an unindented keyword is not matched. Every added alternative costs time (`censor_repo` on the demo confs: 12 s with dynamic regexes, 1.9 s with the generated regex constants: gawk recompiles a dynamic regex at every line once more than 6 are in use).

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
      regexinventory=.*switch.* scope=/inventory/scope.txt \
      regexos=cisco-ios|cisco-xe regexpathexclude=_backup \
      regexinventoryexclude=none

gmake database_email_add audit=client1 dst=john@example.com,jane@example.com \
      cc=manager@example.com

gmake database_postaudit_add audit=client1
```

