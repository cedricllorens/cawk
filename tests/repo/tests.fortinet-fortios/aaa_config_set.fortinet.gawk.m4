#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : aaa_config_set.fortinet.gawk
# @supplier : fortinet-fortios
# @purpose : check if <aaa config> is set
# @description : partial aaa configuration setup could endanger device security (authentication, authorization, and accounting must be configured)
# @actions : missing statements should be added to the configuration or setup exceptions (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : IA-2 | Identification and Authentication | Ensure unique identification and authentication of organizational users is configured
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

`/^config user (tacacs|radius)/',`
	print_err("aaa_config_set.fortinet.gawk",$0,FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("aaa_config_set.fortinet.gawk","<aaa config> is not set",0,"high","error");
}

END {
}
