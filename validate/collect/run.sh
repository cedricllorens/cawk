#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the cawk collectors (database/collectors/) and of their link
#               with the sync (confs/collect_<audit> -> confs/run_<audit>)
# Usage       : gmake check_collect   (or: sh validate/collect/run.sh, from the cawk root)
# Note        : no network: scp and rsync are replaced by shims (local runs for real) serving a fake central system (a directory),
#               a temporary audit is created
#               and deleted; db_sync.txt and db_collect.txt are verified unchanged at the end
#==============================================================================

AUDIT=collecttest
SCOPE="database/sync_scopes/collect_$AUDIT.txt"

if [ ! -f Makefile ] || [ ! -d database/collectors ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ -d "reports/run_$AUDIT" ]; then
	echo "cawk error: audit $AUDIT already exists, delete it first ----"
	exit 2
fi

W=$(mktemp -d)
pass=0
fail=0
for db in db_sync.txt db_collect.txt; do
	if [ -f "database/$db" ]; then cp -p "database/$db" "$W/$db.before"; fi
done

cleanup() {
	gmake delete_audit audit=$AUDIT > /dev/null 2>&1
	rm -f "$SCOPE"
	for db in db_sync.txt db_collect.txt; do
		if [ -f "$W/$db.before" ]; then cp -p "$W/$db.before" "database/$db"; else rm -f "database/$db"; fi
	done
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

# t DESCRIPTION COMMAND... : the command must succeed ; tn : it must fail
t()  { d=$1; shift; if "$@" > /dev/null 2>&1; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL: $d"; fi; }
tn() { d=$1; shift; if "$@" > /dev/null 2>&1; then fail=$((fail + 1)); echo "FAIL: $d"; else pass=$((pass + 1)); fi; }
mtime() { stat -c %Y "$1"; }
same_mtime() { [ "$(mtime "$1")" = "$(mtime "$2")" ]; }
rc_is() { [ "$1" -eq "$2" ]; }
run() { sh "database/collectors/$1.collector.sh" "$AUDIT" "$2" "$3" > "$W/out" 2> "$W/err"; echo $?; }

# ---- shims: the central unix/linux system is the directory $SHIM_SRC ----
mkdir -p "$W/bin"
cat > "$W/bin/scp" <<'EOF'
#!/bin/sh
echo "$*" >> "$SHIM_LOG"
for a in "$@"; do dest=$a; src=$prev; prev=$a; done
case $src in *down*) echo "ssh: connect to host $src port 22: Connection timed out" >&2; exit 255 ;; esac
case $src in *empty*) echo "scp: /srv/confs/*: No such file or directory" >&2; exit 1 ;; esac
cp -rp "$SHIM_SRC"/. "$dest"
EOF
cat > "$W/bin/rsync" <<'EOF'
#!/bin/sh
echo "$*" >> "$SHIM_LOG"
for a in "$@"; do dest=$a; src=$prev; prev=$a; done
case $src in *down*) echo "rsync: connection unexpectedly closed" >&2; exit 12 ;; esac
cp -rp "$SHIM_SRC"/. "$dest"
EOF
chmod 755 "$W/bin/scp" "$W/bin/rsync"
PATH="$W/bin:$PATH"
export SHIM_LOG="$W/ssh.log"
export SHIM_SRC="$W/src"

# the central system: one file per device
mkdir -p "$W/src/.git" "$W/src_empty"
printf 'hostname sw1\n!\nline vty 0 4\n login\n!\nend\n' > "$W/src/sw1"
printf 'hostname sw2\n!\nline vty 0 4\n login\n!\nend\n' > "$W/src/sw2"
printf 'hostname crlf1\r\n!\r\nend\r\n' > "$W/src/crlf1"
printf 'bad name\n' > "$W/src/bad name"
touch -d 2020-01-01 "$W/src/sw1"
ARGS="host=central.example,user=cawk,remote_path=/srv/confs/"

# ---- local ----
mkdir -p "$W/localsrc"
cp -p "$W/src/sw1" "$W/src/sw2" "$W/localsrc/"
printf 'bad name\n' > "$W/localsrc/bad name"
mkdir -p "$W/localsrc/.git"
rc=$(run local "$W/d5" "source_path=$W/localsrc")
t "local: invalid device name gives exit code 1" rc_is "$rc" 1
t "local: device collected" test -f "$W/d5/sw1"
t "local: configuration kept" grep -q '^hostname sw1$' "$W/d5/sw1"
t "local: modification time kept" same_mtime "$W/src/sw1" "$W/d5/sw1"
tn "local: directory not collected" test -e "$W/d5/.git"
tn "local: invalid device name not collected" test -e "$W/d5/bad name"
t "local: scope file built" grep -qx sw2 "$SCOPE"
rm -f "$W/localsrc/bad name" "$W/localsrc/sw2"
rc=$(run local "$W/d5" "source_path=$W/localsrc")
t "local: exit code 0 after a device is removed" rc_is "$rc" 0
tn "local: removed device pruned" test -e "$W/d5/sw2"
rc=$(run local "$W/d5" "source_path=$W/nodir")
t "local: missing directory gives exit code 1" rc_is "$rc" 1
t "local: missing directory keeps the previous configuration" test -f "$W/d5/sw1"
rc=$(run local "$W/d5" "source_path=relative/dir")
t "local: a relative source_path is a usage error (2)" rc_is "$rc" 2
rc=$(run local "$W/d5" "none")
t "local: no source_path is a usage error (2)" rc_is "$rc" 2

# ---- rsync ----
rc=$(run rsync "$W/d1" "$ARGS")
t "rsync: invalid device name gives exit code 1" rc_is "$rc" 1
t "rsync: device collected" test -f "$W/d1/sw1"
t "rsync: configuration kept" grep -q '^hostname sw1$' "$W/d1/sw1"
t "rsync: modification time kept" same_mtime "$W/src/sw1" "$W/d1/sw1"
tn "rsync: directory not collected" test -e "$W/d1/.git"
tn "rsync: invalid device name not collected" test -e "$W/d1/bad name"
t "rsync: invalid device name reported" grep -q "invalid device name" "$W/err"
t "rsync: scope file built" grep -qx sw2 "$SCOPE"
t "rsync: automatic command with the defaults" grep -qF -- "-rt --timeout=30 -e ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -p 22 cawk@central.example:/srv/confs/ " "$W/ssh.log"
rm -f "$W/src/bad name"
rc=$(run rsync "$W/d1" "$ARGS")
t "rsync: exit code 0 once the invalid name is gone" rc_is "$rc" 0
mv "$W/src/sw2" "$W/sw2.keep"
rc=$(run rsync "$W/d1" "$ARGS")
t "rsync: exit code 0 after a device is removed" rc_is "$rc" 0
tn "rsync: removed device pruned" test -e "$W/d1/sw2"
mv "$W/sw2.keep" "$W/src/sw2"
rc=$(SHIM_SRC="$W/src_empty" run rsync "$W/d1" "$ARGS")
t "rsync: empty source does not empty the destination" test -f "$W/d1/sw1"
rc=$(run rsync "$W/d1" "host=down.example,user=cawk,remote_path=/srv/confs/")
t "rsync: failing rsync gives exit code 1" rc_is "$rc" 1
t "rsync: failing rsync keeps the previous configuration" test -f "$W/d1/sw1"
rc=$(run rsync "$W/d1" "$ARGS,key=/k/id,port=2222,timeout=5,hostkey=accept-new,options=--bwlimit=1000+--compress")
t "rsync: key, port, timeout, hostkey and options in the command" grep -qF -- "-rt --timeout=5 -e ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -p 2222 -i /k/id --bwlimit=1000 --compress cawk@central.example:/srv/confs/ " "$W/ssh.log"
t "rsync: an IPv6 address is bracketed" sh -c "sh database/collectors/rsync.collector.sh $AUDIT '$W/d1' 'host=fe80::1,user=cawk,remote_path=/srv/confs/' > /dev/null 2>&1; grep -q 'cawk@\[fe80::1\]:/srv/confs/' '$W/ssh.log'"
t "rsync: a remote_path without trailing slash still copies its content" sh -c "sh database/collectors/rsync.collector.sh $AUDIT '$W/d1' 'host=central.example,user=cawk,remote_path=/srv/confs' > /dev/null 2>&1; grep -qF -- 'cawk@central.example:/srv/confs/ ' '$W/ssh.log'"
rc=$(run rsync "$W/d1" "$ARGS,options=--bwlimit=1;id")
t "rsync: options with an unsupported character is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=central.example,user=cawk,remote_path=/srv/confs/,timeout=abc")
t "rsync: invalid timeout is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=central.example,user=bad;user,remote_path=/srv/confs/")
t "rsync: invalid user is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=-oProxyCommand=x,user=cawk,remote_path=/srv/confs/")
t "rsync: a host starting with a dash is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=central.example,user=cawk,remote_path=srv/confs/")
t "rsync: a relative remote_path is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=central.example,remote_path=/srv/confs/")
t "rsync: no user is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "host=central.example,user=cawk")
t "rsync: no remote_path is a usage error (2)" rc_is "$rc" 2
rc=$(run rsync "$W/d1" "none")
t "rsync: no host is a usage error (2)" rc_is "$rc" 2

# ---- scp ----
printf 'bad name\n' > "$W/src/bad name"
rc=$(run scp "$W/d4" "$ARGS")
t "scp: invalid device name gives exit code 1" rc_is "$rc" 1
t "scp: device collected" test -f "$W/d4/sw1"
t "scp: configuration kept" grep -q '^hostname sw1$' "$W/d4/sw1"
t "scp: modification time kept" same_mtime "$W/src/sw1" "$W/d4/sw1"
tn "scp: CRLF removed" grep -q "$(printf '\r')" "$W/d4/crlf1"
tn "scp: directory not collected" test -e "$W/d4/.git"
tn "scp: invalid device name not collected" test -e "$W/d4/bad name"
t "scp: invalid device name reported" grep -q "invalid device name" "$W/err"
t "scp: scope file built" grep -qx sw2 "$SCOPE"
t "scp: automatic command with the defaults" grep -qF -- "-rpq -B -o ConnectTimeout=20 -o StrictHostKeyChecking=yes -P 22 cawk@central.example:/srv/confs/* " "$W/ssh.log"
rm -f "$W/src/bad name"
rc=$(run scp "$W/d4" "$ARGS")
t "scp: exit code 0 once the invalid name is gone" rc_is "$rc" 0
mv "$W/src/sw2" "$W/sw2.keep"
rc=$(run scp "$W/d4" "$ARGS")
t "scp: exit code 0 after a device is removed" rc_is "$rc" 0
tn "scp: removed device pruned" test -e "$W/d4/sw2"
mv "$W/sw2.keep" "$W/src/sw2"
rc=$(run scp "$W/d4" "host=down.example,user=cawk,remote_path=/srv/confs/")
t "scp: unreachable host gives exit code 1" rc_is "$rc" 1
t "scp: unreachable host reported" grep -q "Connection timed out" "$W/err"
t "scp: unreachable host keeps the previous configuration" test -f "$W/d4/sw1"
rc=$(run scp "$W/d4" "host=empty.example,user=cawk,remote_path=/srv/confs/")
t "scp: a failing copy gives exit code 1" rc_is "$rc" 1
t "scp: a failing copy keeps the previous configuration" test -f "$W/d4/sw1"
rc=$(run scp "$W/d4" "$ARGS,key=/k/id,port=2222,timeout=5,hostkey=accept-new,options=-4+-o+ServerAliveInterval=5")
t "scp: key, port, timeout, hostkey and options in the command" grep -qF -- "-rpq -B -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new -P 2222 -i /k/id -4 -o ServerAliveInterval=5 cawk@central.example:/srv/confs/* " "$W/ssh.log"
t "scp: an IPv6 address is bracketed" sh -c "sh database/collectors/scp.collector.sh $AUDIT '$W/d4' 'host=fe80::1,user=cawk,remote_path=/srv/confs/' > /dev/null 2>&1; grep -qF 'cawk@[fe80::1]:/srv/confs/*' '$W/ssh.log'"
rc=$(run scp "$W/d4" "$ARGS,options=-o+ProxyCommand=id;x")
t "scp: options with an unsupported character is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "$ARGS,hostkey=no")
t "scp: invalid hostkey value is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "$ARGS,port=abc")
t "scp: invalid port is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "host=-oProxyCommand=x,user=cawk,remote_path=/srv/confs/")
t "scp: a host starting with a dash is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "host=central.example,remote_path=/srv/confs/")
t "scp: no user is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "host=central.example,user=cawk")
t "scp: no remote_path is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "host=central.example,user=cawk,remote_path=srv/confs")
t "scp: a relative remote_path is a usage error (2)" rc_is "$rc" 2
rc=$(run scp "$W/d4" "none")
t "scp: no host is a usage error (2)" rc_is "$rc" 2

# ---- make targets and link with the sync ----
gmake create_audit audit=$AUDIT > "$W/create.log" 2>&1
t "create_audit" test -d "reports/run_$AUDIT"
t "create_audit: db_collect.txt default entry (collector=none args=none)" grep -qx "$AUDIT none none" database/db_collect.txt
gmake collect_run audit=$AUDIT > "$W/run0.log" 2>&1
t "collect_run: the default entry (collector none) is skipped, exit code 0" sh -c "grep -q 'no collector configured' '$W/run0.log'"
tn "collect_run: the default entry creates no confs/collect_$AUDIT" test -e "confs/collect_$AUDIT"

gmake database_collect_add audit=$AUDIT collector=rsync "args=$ARGS" sync=yes > "$W/add.log" 2>&1
t "database_collect_add: db_collect.txt entry" grep -qx "$AUDIT rsync $ARGS" database/db_collect.txt
t "database_collect_add sync=yes: db_sync.txt references the collect directory" sh -c "grep '^$AUDIT ' database/db_sync.txt | awk '{print \$2}' | grep -qx '../collect_$AUDIT/'"
t "database_view shows db_collect.txt" sh -c "gmake database_view | grep -q '^$AUDIT rsync'"
t "database_view_collect shows db_collect.txt" sh -c "gmake database_view_collect | grep -q '^$AUDIT rsync'"
t "database_view_collect shows the field format and an example before the closing separator" sh -c "gmake database_view_collect | sed -n '/^format  *: audit collector args/,/^-----/p' | grep -q '^example'"
t "database_view shows the field format of every database" sh -c "[ \$(gmake database_view | grep -c '^format  *: audit') -eq 4 ]"
t "database_view_sync shows the field format" sh -c "gmake database_view_sync | grep -q '^format  *: audit sync_paths'"
t "database_collect_add replaces the default entry" sh -c "[ \$(grep -c '^$AUDIT ' database/db_collect.txt) -eq 1 ]"
t "database_view shows db_collect.txt before db_sync.txt" sh -c "gmake database_view | grep 'cawk view' | sed -n 1p | grep -q db_collect.txt"
tn "database_collect_add: duplicate refused" gmake database_collect_add audit=$AUDIT collector=rsync args=none
tn "database_collect_add: unknown collector refused" gmake database_collect_add audit=$AUDIT collector=nosuch args=none
gmake database_collect_sync audit=$AUDIT > /dev/null 2>&1
t "database_collect_sync is idempotent" sh -c "[ \$(grep '^$AUDIT ' database/db_sync.txt | awk '{print \$2}' | tr ',' '\n' | grep -c collect_$AUDIT) -eq 1 ]"

gmake collect_run audit=$AUDIT > "$W/run.log" 2>&1
t "collect_run: exit code 0" test $? -eq 0
t "collect_run: device collected in confs/collect_$AUDIT" test -f "confs/collect_$AUDIT/sw1"
tn "collect_run: no coherence warning when the sync references the directory" grep -q "does not reference" "$W/run.log"

gmake sync_run audit=$AUDIT > "$W/sync.log" 2>&1
t "sync_run: link built in confs/run_$AUDIT/confs.cisco-ios" test -L "confs/run_$AUDIT/confs.cisco-ios/sw1"
t "sync_run: the link resolves to the collected configuration" grep -q '^hostname sw1$' "confs/run_$AUDIT/confs.cisco-ios/sw1"
t "sync_run: the link resolves into confs/collect_$AUDIT" sh -c "[ \"\$(readlink -f confs/run_$AUDIT/confs.cisco-ios/sw1)\" = \"\$(readlink -f confs/collect_$AUDIT/sw1)\" ]"

printf 'hostname sw5\n!\nline vty 0 4\n login\n!\nend\n' > "$W/src/sw5"
gmake sync_run audit=$AUDIT > /dev/null 2>&1
tn "sync_run without COLLECT: nothing collected" test -e "confs/run_$AUDIT/confs.cisco-ios/sw5"
gmake sync_run audit=$AUDIT COLLECT=yes > "$W/sync2.log" 2>&1
t "sync_run COLLECT=yes: collects then syncs" test -L "confs/run_$AUDIT/confs.cisco-ios/sw5"

gmake database_sync_update audit=$AUDIT dir=none regexinventory=.* scope=none regexos=.* regexpathexclude=none regexinventoryexclude=none > /dev/null 2>&1
gmake collect_run audit=$AUDIT > "$W/run2.log" 2>&1
t "collect_run: warns when the sync does not reference the collect directory" grep -q "does not reference" "$W/run2.log"

gmake database_collect_del audit=$AUDIT > /dev/null 2>&1
tn "database_collect_del: entry removed" grep -q "^$AUDIT " database/db_collect.txt
gmake database_collect_add audit=$AUDIT collector=rsync "args=$ARGS" > /dev/null 2>&1
gmake create_audit audit=$AUDIT supplier=cisco-ios > "$W/create2.log" 2>&1
t "create_audit supplier=: succeeds when a collector is configured" test $? -eq 0
t "create_audit supplier=: keeps the configured collector" grep -qx "$AUDIT rsync $ARGS" database/db_collect.txt
gmake delete_audit audit=$AUDIT > /dev/null 2>&1
tn "delete_audit: collect directory removed" test -e "confs/collect_$AUDIT"
tn "delete_audit: db_collect.txt entry removed" grep -q "^$AUDIT " database/db_collect.txt
tn "delete_audit: scope file removed" test -e "$SCOPE"

# ---- the databases are back to their initial state ----
for db in db_sync.txt db_collect.txt; do
	if [ -f "$W/$db.before" ]; then
		t "$db unchanged" cmp -s "$W/$db.before" "database/$db"
	else
		t "$db unchanged (absent before: empty or absent now)" sh -c "[ ! -s database/$db ]"
	fi
done

echo "cawk collect validation: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
