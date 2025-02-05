#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if an interface has no <cdp enable>
# author  : cedric llorens
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
		print_err("int_cdpenable_notset.cisco-ios.gawk",interface" <cdp enable> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ cdp enable/',`cdpenable = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_cdpenable_notset.cisco-ios.gawk","interface <cdp enable> is not set",0,"high","pass");
}

END {
}
