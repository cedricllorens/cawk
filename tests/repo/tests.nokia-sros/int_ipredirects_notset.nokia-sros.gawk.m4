#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_ipredirects_notset.nokia-sros.gawk
# @supplier : nokia-sros
# @purpose : check if an interface has no <ip redirects>
# @description : ip redirects enabled on interfaces can be exploited to redirect traffic through unauthorized gateways
# @actions : disable ip redirects on all interfaces (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SI-2 | System and Information Integrity | Ensure flaw remediation and patching is configured
# @risk_level : high
# @authors : cedric llorens
# -------------------------------------------------------------------

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

`/^%SED_BK_NOKIA%{1}router/',`',
`/^%SED_BK_NOKIA%{1}exit$/',`', 

`/^%SED_BK_NOKIA%{2}interface/',`
	interface = $0;
',
`/^%SED_BK_NOKIA%{2}exit$/',`', 

`/^%SED_BK_NOKIA%{3}ip redirects/',`
	print_err("int_ipredirects_notset.nokia-sros.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_ipredirects_notset.nokia-sros.gawk","interface <ip redirects> is not set",0,"high","pass");
}

END {
}
