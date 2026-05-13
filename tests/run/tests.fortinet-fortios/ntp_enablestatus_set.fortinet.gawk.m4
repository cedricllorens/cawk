#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : ntp_enablestatus_set.fortinet.gawk
# @supplier : fortinet-fortios
# @purpose : check if <ntp enable status> is set
# @description : missing ntp enable status configuration can lead to time synchronization issues affecting log correlation and security auditing
# @actions : set <ntp enable status> (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : AU-8(1) | Audit and Accountability | Ensure time synchronization with authoritative source is configured
# @risk_level : high
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
