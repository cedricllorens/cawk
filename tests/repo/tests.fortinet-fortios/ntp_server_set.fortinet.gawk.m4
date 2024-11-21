#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if ntp server is set
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

`/^config ntpserver/', `',
`/^end$/', `',

`/^%SED_BK_FORTI%edit/', `',
`/^%SED_BK_FORTI%next$/', `',

`/^%SED_BK_FORTI%{2}set server/', `
	print_err("ntp_enablestatus_set.fortinet.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ntp_enablestatus_set.fortinet.gawk","ntp server is not set",0,"high","error");
}

END {
}
