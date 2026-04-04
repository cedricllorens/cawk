#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_icmpunreachable_notset.paloalto-panos
# @supplier : paloalto-panos
# @purpose : check if an interface has no <icmp-unreachable yes>
# @description : icmp unreachables enabled on interfaces may reveal network topology information to potential attackers
# @actions : disable icmp-unreachable on all interfaces (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 2.3.5 | Ensure ICMP unreachables are disabled | Network Protocols
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

`/^%SED_BK_PALO%{5}icmp-unreachable yes/',`
	print_err("int_icmpunreachable_notset.paloalto-panos.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_icmpunreachable_notset.paloalto-panos.gawk","interface <icmp-unreachable yes> is not set",0,"high","pass");
}

END {
}
