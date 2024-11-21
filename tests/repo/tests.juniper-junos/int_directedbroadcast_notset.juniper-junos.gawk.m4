#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if an interface has no <directed-broadcast>
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

dnl ----

`/^interfaces {$/',`',
`/^}$/',`', 

dnl ----

`/%SED_BK_JUNI%[^ ]+ {/',`',
`/^%SED_BK_JUNI%}$/',`',

dnl ----

`/%SED_BK_JUNI%{2}unit [^ ]+ {/',`
	interface = rm_blank_before($0);
	interfaceno = FNR;
	directedbroadcast = 0;
',
`/^%SED_BK_JUNI%{2}}$/',`
	if ( directedbroadcast == 1 ) {
		print_err("int_directedbroadcast_notset.juniper-junos.gawk",interface" <directed-broadcast> is set",interfaceno,"high","error");
		pass = 0;
	}
',

dnl ----

`/%SED_BK_JUNI%{3}family inet.* {/',`',
`/^%SED_BK_JUNI%{3}}$/',`',

dnl ----

`/^%SED_BK_JUNI%{4}directed-broadcast/',`directedbroadcast = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_directedbroadcast_notset.juniper-junos.gawk","interface <directed-broadcast> is not set",0,"high","pass");
}

END {
}