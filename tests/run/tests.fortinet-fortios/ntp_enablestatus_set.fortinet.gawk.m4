#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <ntp enable status> is set
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

`/^config system ntp/',`',
`/^end$/', `',

`/^%SED_BK_FORTI%set status enable/', `
	print_err("ntp_enablestatus_set.fortinet.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `',

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ntp_enablestatus_set.fortinet.gawk","ntp enable status is not set",0,"high","error");
}

END {
}
