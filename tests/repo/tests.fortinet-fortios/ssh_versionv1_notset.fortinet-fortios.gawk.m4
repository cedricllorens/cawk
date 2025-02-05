#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <ssh server> is not set
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

`/^config system global/', `',
`/^end$/', `',

`/%SED_BK_FORTI%set admin-ssh-.* enable/ && /v1/', `
	print_err("ssh_versionv1_set.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ssh_versionv1_set.fortinet-fortios.gawk","<ssh server> is not set",0,"high","pass");
}

END {
}
