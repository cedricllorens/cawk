dnl ------------------------------------------------------------
dnl cawk is subject to a MIT open-source licence
dnl please refer to the MIT licence file for further information
dnl ------------------------------------------------------------
dnl CENSOR RULES OF THIS INSTALLATION (database/censor/censor_regex.m4)
dnl
dnl two independent parts, built by gmake into database/censor/censor_regex (generated file, never edit it):
dnl   1. the CORE rules shipped by cawk, in common/censor/censor_regex_core.m4 (included below):
dnl      owned by cawk, replaced by every new version, never saved nor restored, do not edit it here nor there
dnl   2. YOUR rules, written after the include, in this file only: owned by you, saved and restored with database/,
dnl      kept as they are by a new cawk version (cawk never rewrites this file)
dnl
dnl KEEP THE INCLUDE LINE BELOW: without it the core rules are lost and gmake check_repo / check_run stop (check_integrity)
dnl (a file restored from an older backup may not have it: add the line, the rules written before the version that introduced the core stay yours)
dnl
dnl your rules use the macros of m4/cawk_censor.m4, the first argument is an extended regex (gawk), they are not nested :
dnl   censor_after(`regex')  : the text following the regex is censored
dnl   censor_match(`regex')  : the text matched by the regex is censored, so the regex must cover the value
dnl   censor_line(`regex')   : the whole line containing a match of the regex is censored (never surround the regex with .*)
dnl   censor_ignore(`regex') : like censor_match, the case is ignored
dnl optional arguments : the case (`lowercaseuppercase'), the level (`internal' by default or `external'), the word printed (CENSORED by default)
dnl example : censor_match(`ACME-[0-9]{6}', `', `internal', `XXXX')
dnl full description of the arguments and of the levels: the header of common/censor/censor_regex_core.m4
dnl ------------------------------------------------------------
include(`censor_regex_core.m4')dnl

dnl ---- YOUR RULES (one regex per line, after this line) ----
