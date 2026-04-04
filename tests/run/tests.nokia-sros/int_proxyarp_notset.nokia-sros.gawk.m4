#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_proxyarp_notset.nokia-sros
# @supplier : nokia-sros
# @purpose : check if an interface has no <ip proxy-arp>
# @description : ip proxy-arp enabled on interfaces can lead to arp spoofing and man-in-the-middle attacks
# @actions : disable ip proxy-arp on all interfaces where it is not explicitly required (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 2.3.2 | Ensure proxy-arp is disabled | Network Protocols
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

`/^%SED_BK_NOKIA%{3}ip proxy-arp/',`
	print_err("int_proxyarp_notset.nokia-sros.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_proxyarp_notset.nokia-sros.gawk","interface <ip proxy-arp> is not set",0,"high","pass");
}

END {
}
