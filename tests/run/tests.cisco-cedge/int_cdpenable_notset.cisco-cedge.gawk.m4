#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_cdpenable_notset.cisco-cedge.gawk
# @supplier : cisco-cedge
# @purpose : check if an interface has no <cdp enable>
# @description : cdp may disclose sensitive information or trigger vulnerabilities
# @actions : set <no cdp enable> on interfaces (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 2.3.1 | Ensure CDP is disabled on interfaces | Network Protocols
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
	cdpenable = 0;
',
`/^!$/', `
	if ( cdpenable == 1 ) {
		print_err("int_cdpenable_notset.cisco-cedge.gawk",interface" <cdp enable> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ cdp enable/',`cdpenable = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_cdpenable_notset.cisco-cedge.gawk","interface <cdp enable> is not set",0,"high","pass");
}

END {
}
