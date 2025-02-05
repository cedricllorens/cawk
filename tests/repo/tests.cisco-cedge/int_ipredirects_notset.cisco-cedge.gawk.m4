#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if an interface has <ip redirects>
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
	noipredirects = 0;
',
`/^!$/', `
	if ( noipredirects == 1 ) {
		print_err("int_noipredirects_set.cisco-cedge.gawk",interface" <ip redirects> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ ip redirects/',`noipredirects = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_noipredirects_set.cisco-cedge.gawk","interface <ip redirects> is not set",0,"high","pass");
}

END {
}
