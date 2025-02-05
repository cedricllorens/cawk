#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if an interface has no <proxy-arp>
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
	proxyarp = 0;
',
`/^%SED_BK_JUNI%{2}}$/',`
	if ( proxyarp == 1 ) {
		print_err("int_proxyarp_notset.juniper-junos.gawk",interface" <proxy-arp> is set",interfaceno,"high","error");
		pass = 0;
	}
',

dnl ----

`/%SED_BK_JUNI%{3}family inet.* {/',`',
`/^%SED_BK_JUNI%{3}}$/',`',

dnl ----

`/^%SED_BK_JUNI%{4}proxyarp/',`proxyarp = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_proxyarp_notset.juniper-junos.gawk","interface <proxy-arp> is not set",0,"high","pass");
}

END {
}
