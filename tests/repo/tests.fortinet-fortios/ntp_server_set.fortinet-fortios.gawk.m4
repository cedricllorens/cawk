#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : ntp_server_set.fortinet-fortios.gawk
# @supplier : fortinet-fortios
# @purpose : check if <ntp server> is set
# @description : missing ntp server configuration can lead to time synchronization issues affecting log correlation and security auditing
# @actions : set <ntp server> with a trusted ntp source (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 3.2.1 | Ensure NTP is configured | Logging and Timestamping
# @authors : cedric llorens
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
	print_err("ntp_server_set.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ntp_server_set.fortinet-fortios.gawk","ntp server is not set",0,"high","error");
}

END {
}
