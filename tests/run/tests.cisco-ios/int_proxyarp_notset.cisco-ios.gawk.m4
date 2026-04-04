#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_proxyarp_notset.cisco-ios
# @supplier : cisco-ios
# @purpose : check if an interface has no <ip proxy-arp>
# @description : ip proxy-arp may trigger attacks
# @actions : set <no ip proxy-arp> on interfaces (please refer to engineering/operations guidelines for further information)
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

dnl level 0 --
`/^interface .*$/',`
	interface = $0;
	interfaceno = FNR;
	proxyarp = 0;
',
`/^!$/', `
	if ( proxyarp == 1 ) {
		print_err("int_proxyarp_notset.cisco-ios.gawk",interface" <ip proxy-arp> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ ip proxy-arp/',`proxyarp = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_proxyarp_notset.cisco-ios.gawk","interface <ip proxy-arp> is not set",0,"high","pass");
}

END {
}
