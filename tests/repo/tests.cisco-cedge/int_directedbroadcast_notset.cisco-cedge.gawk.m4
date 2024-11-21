#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if an interface has no <ip directed-broadcast>
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

`/^interface .*$/',`
	interface = $0;
	interfaceno = FNR;
	directedbroadcast = 0;
',
`/^!$/', `
	if ( directedbroadcast == 1 ) {
		print_err("int_directedbroadcast_notset.cisco-cedge.gawk",interface" <ip directed-broadcast> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

`/^ ip directed-broadcast/',`directedbroadcast = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_directedbroadcast_notset.cisco-cedge.gawk","interface <ip directed-broadcast> is not set",0,"high","pass");
}

END {
}
