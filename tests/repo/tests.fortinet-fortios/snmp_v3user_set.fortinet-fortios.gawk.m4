#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : snmp_v3user_set.fortinet-fortios.gawk
# @supplier : fortinet-fortios
# @purpose : check if <snmp v3 user> is set
# @description : missing snmp v3 user with auth and priv means snmp v3 authentication and encryption are not properly configured
# @actions : set <snmp-server user> with proper auth and priv settings (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.6.4 | Ensure SNMPv3 users are configured | SNMP
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

`/^config system snmp user/', `',
`/^end$/', `',

`/%SED_BK_FORTI%edit/', `
	print_err("snmp_v3user_set.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("snmp_v3user_set.fortinet-fortios.gawk","<snmp v3 user> is not set",0,"high","error");
}

END {
}
