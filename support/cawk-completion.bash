# bash completion for gmake in a cawk directory: targets, audit=, supplier=, common options
# install: source support/cawk-completion.bash from the cawk root directory, or everywhere with these lines in ~/.bashrc:
#   export CAWK_HOME=/home/cedric/Documents/cawk
#   source "$CAWK_HOME/support/cawk-completion.bash"
# outside a cawk root directory (no Makefile + support/) it falls back to the default completion
_cawk_targets() {
	local cache=tmp/cawk_targets.cache
	if [ ! -s "$cache" ] || [ -n "$(find Makefile support -maxdepth 1 -name 'Makefile*' -newer "$cache" 2>/dev/null | head -1)" ]; then
		mkdir -p tmp && gmake --no-print-directory -pRrq : 2>/dev/null | awk -F: '/^[a-zA-Z][a-zA-Z0-9_]+:/ && !seen[$1]++ { print $1 }' | LC_ALL=C sort > "$cache.$$" && mv "$cache.$$" "$cache"
	fi
	cat "$cache"
}

# options and their values, read from vars.mk (never written here): yes/no options (NAME ?= yes|no), CENSOR_LEVEL, collectors of database/collectors
_cawk_bool_options() {
	awk '/^[A-Z][A-Z0-9_]* *\?= *(yes|no)([ \t]|$)/ { print $1 }' support/Makefile.support.vars.mk
}

_cawk_complete() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	if [ ! -f Makefile ] || [ ! -d support ]; then
		declare -F _make >/dev/null && _make "$@"
		return
	fi
	case $cur in
		audit=*)
			local a
			COMPREPLY=($(compgen -W "$(for a in tests/run_*; do [ -d "$a" ] && echo "audit=${a#tests/run_}"; done)" -- "$cur"))
			;;
		supplier=*)
			local s
			COMPREPLY=($(compgen -W "$(for s in tests/repo/tests.*; do case $s in *.psirt) ;; *) echo "supplier=${s#tests/repo/tests.}" ;; esac; done)" -- "$cur"))
			;;
		CENSOR_LEVEL=*)
			COMPREPLY=($(compgen -W "CENSOR_LEVEL=internal CENSOR_LEVEL=external" -- "$cur"))
			;;
		collector=*)
			local c
			COMPREPLY=($(compgen -W "$(for c in database/collectors/*.collector.sh; do [ -f "$c" ] && c=${c##*/} && echo "collector=${c%.collector.sh}"; done)" -- "$cur"))
			;;
		topic=*)
			COMPREPLY=($(compgen -W "$(_cawk_targets | sed 's/^/topic=/')" -- "$cur"))
			;;
		*=*)
			local n=${cur%%=*}
			if [ "$n" = FORCE ] || _cawk_bool_options | grep -qx "$n"; then
				COMPREPLY=($(compgen -W "$n=yes $n=no" -- "$cur"))
			else
				COMPREPLY=()
			fi
			;;
		*)
			COMPREPLY=($(compgen -W "$(_cawk_targets) audit= supplier= collector= topic= in= out= args= FORCE= CENSOR_LEVEL= $(_cawk_bool_options | sed 's/$/=/')" -- "$cur"))
			[ "${#COMPREPLY[@]}" -eq 1 ] && case ${COMPREPLY[0]} in *=) compopt -o nospace 2>/dev/null ;; esac
			;;
	esac
}

complete -F _cawk_complete gmake
