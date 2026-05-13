#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_ipredirects_notset.cisco-xe.gawk
# @supplier : cisco-xe
# @purpose : check if an interface has no <ip redirects>
# @description : ip redirects may trigger attacks
# @actions : set <no ip redirects> on interfaces (please refer to engineering/operations guidelines for further information)
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

dnl level 0 --
`/^interface .*$/',`
	interface = $0;
	interfaceno = FNR;
	ipredirects = 0;
',
`/^!$/', `
	if ( ipredirects == 1 ) {
		print_err("int_ipredirects_notset.cisco-xe.gawk",interface" <ip redirects> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ ip redirects/',`ipredirects = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_ipredirects_notset.cisco-xe.gawk","interface <ip redirects> is not set",0,"high","pass");
}

END {
}
