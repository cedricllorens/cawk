#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if an interface has no <proxy-arp yes>
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

`/^network/',`',
`/^\}$/',`', 

`/^%SED_BK_PALO%{1}interface /',`',
`/^%SED_BK_PALO%{1}\}$/',`', 

`/^%SED_BK_PALO%{2}.*$/',`',
`/^%SED_BK_PALO%{2}\}$/',`', 

`/^%SED_BK_PALO%{3}.*$/',`
	interface = $0;
',
`/^%SED_BK_PALO%{3}\}$/',`', 

`/^%SED_BK_PALO%{4}layer3 /',`',
`/^%SED_BK_PALO%{4}\}$/',`', 

`/^%SED_BK_PALO%{5}proxy-arp yes/',`
	print_err("int_proxyarp_notset.paloalto-panos.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_proxyarp_notset.paloalto-panos.gawk","interface <proxy-arp yes> is not set",0,"high","pass");
}

END {
}
