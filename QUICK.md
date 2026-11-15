<p align="left"><img src="docs/logo/logo-cawk-pro.svg" width="200" alt="cawk"></p>

# cawk QUICK

> **cawk is subject to an MIT open-source license**
> **cawk is Copyright (C) 2024-2026 by Cedric Llorens**

Goal: from "I have configurations" to "I have an audit report". Details: [README](README.md#cawk-workflow).

```
 your confs ──(A: collector)──> confs/collect_client1/ ──┐
 (one file per device)                                   ├──[2 SYNC]──> confs/run_client1/confs.<supplier>/ ──[3 RUN]──> reports/run_client1/
 on this machine  ───────────(B: nothing to collect)─────┘
```

- **audit**: a named workspace (`audit=client1`), with its own tests, confs and reports.
- **conf**: the config file of ONE device. **supplier**: its vendor/os (`cisco-ios`...), detected by cawk.
- **collector**: an OPTIONAL script that copies the confs from a remote server. **You do not need it if the confs are already on the cawk machine** (path B: declare their folder in the sync database, step 2).

## 0. Create the audit (once)

**Script run:** none. It only creates the folders and one default line in each database.

```sh
gmake create_audit audit=client1
```

## 1. Collect the confs (path A only, optional)

The confs are on a remote server: declare a collector once in the collect database, then run it (`scp` or `rsync`; needs an ssh key and the server host key known).

**Script run:** `database/collectors/scp.collector.sh` (or `rsync`, `local`), chosen by the collect database. WHY: it is the only moment cawk touches the remote server, to copy the confs (read only). It is not in `database/scripts` and nothing else calls it.

```sh
gmake database_collect_add audit=client1 collector=scp sync=yes \
      args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519
gmake collect_run audit=client1        # copies into confs/collect_client1/ (secrets inside: never share)
```

Path B (the confs are already on the cawk machine): skip this step, there is nothing to collect.

## 2. Sync: declare where the confs are, then sort them by supplier

Like the collector, the sync reads its settings from a database (`database/db_sync.txt`): declare them once, then run.

| Path | Declare the sync entry (once) |
|---|---|
| **A** collector | already done by `sync=yes` at step 1 (it wrote `dir=../collect_client1/`) |
| **B** local confs | `gmake database_sync_update audit=client1 dir=/data/confs/ regexinventory=.* scope=none regexos=.* regexpathexclude=none regexinventoryexclude=none` |

- `dir=` : the folder(s) holding ONE FILE PER DEVICE (comma separated, no space).
- `regexos=` : which suppliers to keep (`.*` = all, `(cisco-ios|juniper-junos)` = two). `regexpathexclude=` : paths or device names to skip (`none` = nothing).
- `scope=` : `create_audit` sets it to `database/sync_scopes/client1_inventory_sync_scope.txt`, an EMPTY file = audit every file found (`none` does the same). To audit only some devices, write their names there, one per line. `regexinventory=` and `regexinventoryexclude=` filter those lines.
- Check the entry: `gmake database_view_sync`.

**Script run:** `database/scripts/database_sync.script` at the start of every `sync_run`. WHY: a hook to build or refresh the scope file of the audit (i.e. from your inventory) before the sync reads it. As shipped it does nothing (its examples are commented): fill the scope file by hand or edit the script. A failure stops the sync (`logs/run_client1/sync.client1.err`). `sync_teststoconfs_run` and `sync_exceptionstoconfs_run` run no script.

```sh
gmake sync_run audit=client1           # A+B. Shortcut for A: gmake sync_run audit=client1 COLLECT=yes
gmake sync_teststoconfs_run audit=client1 && gmake sync_exceptionstoconfs_run audit=client1   # keep only the useful tests
ls confs/run_client1/confs.*/          # check: each device is in the folder of its supplier
```

The confs are soft links rebuilt at each sync: edit a conf at its source, never in `confs/run_client1`.

## 3. Run and read

```sh
gmake check_run audit=client1          # phase lines (VERBOSE=yes, default), then a recap: duration, results by status and risk, report path
gmake view_run_error audit=client1     # errors only: start here
```

A result line is `conf | test | error_line | line_nb | risk | status`: status `pass` `error` `warning` `psirt`, risk `high` `medium` `low` `info`.
To fix it: change the conf at its source, then run again. To accept it: write an exception in `exceptions/run_client1/exceptions.<supplier>.m4`.

Options: `supplier=cisco-ios` (one supplier), `MAKE_PARALLEL=yes` (big audits), `PSIRT_ONLY=yes` / `STANDARD_ONLY=yes`, `HTML=yes` (one standalone summary page for the customer, `reports/run_client1/assessment.all.summary.html`), `VERBOSE=no` (final recap only; default `yes` prints the line of every phase).

Lost at any step? `gmake status audit=client1` shows the confs per supplier, the last assessment and the next command to run. `gmake help topic=WORD` searches a word in the help, `source support/cawk-completion.bash` gives the tab completion in bash (everywhere: `export CAWK_HOME=/home/cedric/Documents/cawk` and `source "$CAWK_HOME/support/cawk-completion.bash"` in `~/.bashrc`).

## 4.Trouble

| Symptom | Look at |
|---|---|
| `cawk error` while collecting | `logs/run_client1/collect.client1.err` (key, host, host key, empty remote dir) |
| device or supplier missing | `ls confs/run_client1/confs.*/`, then the sync database (`gmake database_view_sync`) |
| start again | `gmake clean_report_run audit=client1`, remove the audit: `gmake delete_audit audit=client1 FORCE=yes` |
