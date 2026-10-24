dnl ------------------------------------------------------------
dnl cawk is subject to a MIT open-source licence
dnl please refer to the MIT licence file for further information
dnl ------------------------------------------------------------

dnl ---------------------------------------------------
dnl Macros generating the regexes read by common/censor.gawk
dnl (database/censor/censor_regex.m4 -> database/censor/censor_regex)
dnl
dnl a generated regex is applied with gensub(regex, "\1<word>", "g") :
dnl the text matched by the group 1 is kept, the rest of the match is censored
dnl
dnl each macro is a command on its own, the macros are not nested : quote the argument
dnl ---------------------------------------------------

dnl ---------------------------------------------------
dnl every macro takes an optional second argument, the option of the regex $1 :
dnl  lowercaseuppercase : the case of $1 is ignored
dnl                       each letter outside of a bracket expression becomes [xX] ; a bracket expression and a
dnl                       backslash escape are kept as written : write both cases inside a bracket
dnl  any other value stops m4 with an error
dnl
dnl every macro takes an optional third argument, the level of the regex :
dnl  internal (default) : applied by every censoring (CENSOR_LEVEL=internal and CENSOR_LEVEL=external)
dnl  external           : applied only when gmake runs with CENSOR_LEVEL=external
dnl  any other value stops m4 with an error
dnl  censor_ignore(`regex', `', `external') : its second argument is unused, the level is always the third
dnl
dnl every macro takes an optional fourth argument, the word printed in place of the censored text :
dnl  CENSORED (default) when empty
dnl  censor_match(`password +[^ ]+', `', `', `XXXX') : enable password 7 0822455D0A16 gives enable XXXX 0822455D0A16
dnl  censor_ignore(`regex', `', `external', `word') : its second argument is unused, the word is always the fourth
dnl  the word must not hold a tab
dnl the generated file is gawk code, see _censor_rule below : common/censor.gawk includes it and applies the rules allowed by CENSOR_LEVEL
dnl a regex is a gawk regex constant : write [/] for a slash
dnl ---------------------------------------------------

dnl ---------------------------------------------------
dnl censor_match($1,$2) : the text matched by $1 is censored
dnl  snmp-server community public RO : censor_match(`community +[^ ]+') gives snmp-server CENSORED public RO
dnl  the blanks of $1 are censored too : censor_match(` secret ') on ` secret x' gives CENSOREDx
dnl ---------------------------------------------------

define(`censor_match', `_censor_rule(`()(', `)', `$1', `$2', `$3', `$4')')

dnl ---------------------------------------------------
dnl censor_line($1,$2) : the whole line containing a match of $1 is censored
dnl  enable password 7 0822455D0A16 : censor_line(`password 7 ') gives CENSORED
dnl ---------------------------------------------------

dnl  generated as a plain match test, never wrap $1 in .* : a leading .* makes the engine retry the match from every position (~87x slower)

define(`censor_line', `	ifelse(_censor_level(`$3'), `external', `if (external) ')if (line ~ /_censor_case(`$1', `$2')/) line = "_censor_word_plain(`$4')"
divert(1)	if ("" ~ /_censor_case(`$1', `$2')/) die("a regex of censor_regex.m4 matches an empty string")
divert(0)')

dnl ---------------------------------------------------
dnl censor_after($1,$2) : the text following $1, up to the end of line, is censored
dnl  a line with nothing after $1 is left untouched
dnl  snmp-server community public RO : censor_after(`snmp-server +[^ ]+') gives snmp-server community CENSORED
dnl ---------------------------------------------------

define(`censor_after', `_censor_rule(`((', `)[ \t]*)[^ \t].*', `$1', `$2', `$3', `$4')')

dnl ---------------------------------------------------
dnl censor_ignore($1) : like censor_match(`$1', `lowercaseuppercase')
dnl  username a PASSWORD abc : censor_ignore(`password +[^ ]+') gives username a CENSORED
dnl ---------------------------------------------------

define(`censor_ignore', `censor_match(`$1', `lowercaseuppercase', `$3', `$4')')

dnl ---------------------------------------------------
dnl the generated file is gawk code (included by common/censor.gawk) :
dnl  censor_apply(line, external) : one statement per rule, in order, the regex is a regex constant compiled once
dnl                                 (a dynamic regex is recompiled at every line once more than 6 are in use)
dnl  censor_check()               : fails on a regex matching an empty string
dnl _censor_rule($1,$2,$3,$4,$5,$6) : the rule of the regex $3 (option $4, level $5, word $6) wrapped in $1 ... $2
dnl ---------------------------------------------------

divert(1)function censor_check() {
divert(0)function censor_apply(line, external) {
m4wrap(`	return line
}
divert(1)}
divert(0)')

define(`_censor_rule', `	ifelse(_censor_level(`$5'), `external', `if (external) ')line = gensub(/$1`'_censor_case(`$3', `$4')`'$2/, "\\1`'_censor_word(`$6')", "g", line)
divert(1)	if ("" ~ /$1`'_censor_case(`$3', `$4')`'$2/) die("a regex of censor_regex.m4 matches an empty string")
divert(0)')

dnl _censor_word($1) : the word $1 as the text of a gawk string used as a gensub replacement, CENSORED when empty
dnl  a backslash, an ampersand and a double quote are escaped
define(`_censor_word', `ifelse(`$1', `', `CENSORED',
`patsubst(patsubst(patsubst(`$1', `\\', `\\\\\\\\'), `&', `\\\\&'), `"', `\\"')')')

dnl _censor_word_plain($1) : the word $1 as the text of a gawk string assigned as is, CENSORED when empty
dnl  a backslash and a double quote are escaped
define(`_censor_word_plain', `ifelse(`$1', `', `CENSORED',
`patsubst(patsubst(`$1', `\\', `\\\\'), `"', `\\"')')')

dnl _censor_level($1) : the level $1, internal when empty
define(`_censor_level', `ifelse($1, `', `internal', $1, `internal', `internal', $1, `external', `external',
`errprint(`cawk error: censor: unknown level <$1> (expected internal or external)
')m4exit(1)')')

dnl _censor_case($1,$2) : the regex $1 with the option $2 applied
define(`_censor_case', `ifelse($2, `', `$1',
$2, `lowercaseuppercase', `_censor_ignore_walk(`$1', `o')',
`errprint(`cawk error: censor: unknown option <$2> (expected lowercaseuppercase)
')m4exit(1)')')

define(`_censor_lower', `abcdefghijklmnopqrstuvwxyz')
define(`_censor_upper', `ABCDEFGHIJKLMNOPQRSTUVWXYZ')

dnl _censor_ignore_out($1,$2) : the output of the character $1 in the state $2
define(`_censor_ignore_out', `ifelse($2, `o',
`ifelse(eval(index(_censor_lower, `$1') >= 0 || index(_censor_upper, `$1') >= 0), 1,
`[$1`'translit(`$1', _censor_lower`'_censor_upper, _censor_upper`'_censor_lower)]', `$1')',
`$1')')

dnl _censor_ignore_state($1,$2) : the state after the character $1 in the state $2
dnl  o = outside, b = in a bracket expression, eo/eb = after a backslash outside/inside
define(`_censor_ignore_state', `ifelse(
$2, `eo', `o',
$2, `eb', `b',
$2, `o', `ifelse(`$1', `\', `eo', `$1', `[', `b', `o')',
`ifelse(`$1', `\', `eb', `$1', `]', `o', `b')')')

dnl _censor_head($1), _censor_tail($1) : the first character and the rest of $1, returned quoted so that
dnl m4 does not read them again (a lone parenthesis or comma would unbalance the arguments of the caller)
define(`_censor_head', `patsubst(`$1', `^\(.\).*', ``\1'')')
define(`_censor_tail', `patsubst(`$1', `^.\(.*\)', ``\1'')')

define(`_censor_ignore_walk', `ifelse(`$1', `', `',
`_censor_ignore_out(_censor_head(`$1'), `$2')`'_censor_ignore_walk(_censor_tail(`$1'), _censor_ignore_state(_censor_head(`$1'), `$2'))')')
