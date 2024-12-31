#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if a fw zone is set
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%

# ----

include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 0;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

`/^zone security .*$/',`
	print_err("fw_zonesecurity_set.cisco-cedge.gawk","fw zone is set : "$0,FNR,"high","pass");
	pass = 1;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( ! pass ) print_err("fw_zonesecurity_set.cisco-cedge.gawk","fw zone is not set",0,"high","error");
}

END {
}
