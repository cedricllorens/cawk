#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if a line vty has <transport intput ssh>
# author  : cedric llorens
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%

# ----

include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

`/^line vty .*$/',`
	linevty = $0;
	linenoaux = FNR;
	transportoutputssh = 0;
',
`/^!$/', `
	if ( transportoutputssh == 0 ) {
		print_err("linevty_transportoutputssh_set.cisco-cedge.gawk",linevty" <transport output ssh> is missing",linenoaux,"high","error");
		pass = 0;
	}
', 

`/^ transport output ssh$/',`transportoutputssh = 1;',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("linevty_transportoutputssh_set.cisco-cedge.gawk","line vty <transport output ssh> is set",0,"high","pass");
}

END {
}
