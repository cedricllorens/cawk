#!/bin/sh
# PreToolUse Write|Edit: enforce the cawk change protocol (CAWK_CODE_RULES.md)
f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0
root=${CLAUDE_PROJECT_DIR:-$PWD}
case "$f" in "$root"/.claude/*|"$root"/*.orig) exit 0 ;; "$root"/*) ;; *) exit 0 ;; esac
case "$f" in
  *.gawk) echo "Compiled .gawk: edit its source (*.gawk.template|m4|include), then gmake tests_repo." >&2; exit 2 ;;
esac
if [ -f "$f" ] && [ ! -f "$f.orig" ]; then
  echo "Backup first: [ ! -f $f.orig ] && cp $f $f.orig" >&2; exit 2
fi
exit 0
