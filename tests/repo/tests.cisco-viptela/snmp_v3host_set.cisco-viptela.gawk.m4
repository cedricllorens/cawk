#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like SED_GAWK_PATH, etc. please refer to 
# file support/tests.sed for further information
#
# purpose : check when a <snmp v3 host> is set
# author  : cedric llorens
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%
include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

dnl level 0 --
`/^snmp/',`',
`/^!$/', `',

dnl level 1 --
`/^ trap(s)?$/',`',
`', `',

dnl level 2 --
`/^[ ][ ]host /',`
	print_err("snmp_v3host_set.cisco-viptela.gawk","snmp v3 host is set : "$0,FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("snmp_v3host_set.cisco-viptela.gawk","snmp v3 host is not set",0,"high","error");
}

END {
}
