#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_proxyarp_notset.juniper-junos.gawk
# @supplier : juniper-junos
# @purpose : check if an interface has no <proxy-arp>
# @description : proxy-arp enabled on interfaces can lead to arp spoofing and man-in-the-middle attacks
# @actions : disable proxy-arp on all interfaces where it is not explicitly required (please refer to engineering/operations guidelines for further information)
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
