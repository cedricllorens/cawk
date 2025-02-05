#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <ssh server> is set
# author  : cedric llorens
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

dnl level 0 --
`/^system$/',`',
`/^!$/', `',

dnl level 2 --
`/ssh-server/',`
	print_err("ssh_setup_set.cisco-viptela.gawk",$0,FNR,"high","pass");
	pass = 1;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( ! pass ) print_err("ssh_setup_set.cisco-viptela.gawk","<ssh server> is not set",0,"high","error");
}

END {
}
