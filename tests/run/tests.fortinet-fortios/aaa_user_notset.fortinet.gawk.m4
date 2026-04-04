#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : aaa_user_notset.fortinet.gawk
# @supplier : fortinet-fortios
# @purpose : check if <aaa users> are not set locally
# @description : local users can endanger the security of the system by allowing unauthorized access
# @actions : remove local users or setup exceptions (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.1.3 | Ensure local users are minimized | System Administration
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

`/^config user (tacacs|radius)/',`',
`/^end/', `',


`/^%SED_BK_FORTI%edit .*$/ && !/edit %SED_AUTHUSER_FORTI%/', `
	print_err("aaa_user_notset.fortinet.gawk",$0,FNR,"high","error");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("aaa_user_notset.fortinet.gawk","aaa forbidden users are not set",0,"high","pass");
}

END {
}
