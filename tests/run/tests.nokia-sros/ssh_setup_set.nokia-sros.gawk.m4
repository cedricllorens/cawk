#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if <ssh server> is set
# -------------------------------------------------------------------

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

`/^%SED_BK_NOKIA%{1}system/',`',
`/^%SED_BK_NOKIA%{1}exit$/',`', 

`/^%SED_BK_NOKIA%{2}security/',`',
`/^%SED_BK_NOKIA%{2}exit$/',`', 

`/^%SED_BK_NOKIA%{3}ssh/',`
	print_err("ssh_setup_set.nokia-sros.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("ssh_setup_set.nokia-sros.gawk","<ssh server> is not set",0,"high","error");
}

END {
}
