#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <snmp v3 host> is set
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

`/^config system snmp user/', `',
`/^end$/', `',

`/%SED_BK_FORTI%edit/', `',
`/^%SED_BK_FORTI%end$/', `',

`/%SED_BK_FORTI%{2}set notify-hosts/', `
	print_err("snmp_v3host_set.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("snmp_v3host_set.fortinet-fortios.gawk","<snmp v3 host> is not set",0,"high","error");
}

END {
}
