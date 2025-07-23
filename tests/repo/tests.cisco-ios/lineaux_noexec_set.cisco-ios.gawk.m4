#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if a line aux has <no exec>
# author  : cedric llorens
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%

# ----

function acl_summary() {
	if ( noexec == 0 ) {
		print_err("lineaux_noexec_set.cisco-ios.gawk",lineaux" <no exec> is missing",linenoaux,"high","error");
		pass = 0;
	}
}

# ----

include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1;
	block_aux = 0;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

`/^line aux .*$/',`
	if ( block_aux == 1 ) acl_summary();
	block_aux = 1;
	lineaux = $0;
	linenoaux = FNR;
	noexec = 0;
',
`( /^!$/ || ( /^line / && !/ aux / ) )', `acl_summary();block_aux = 0;', 

`/^ no exec$/',`noexec = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("lineaux_noexec_set.cisco-ios.gawk","line aux <no exec> is set",0,"high","pass");
}

END {
}
