#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_unreachables_notset.juniper-junos
# @supplier : juniper-junos
# @purpose : check if an interface has no <unreachables>
# @description : icmp unreachables enabled on interfaces may reveal network topology information to potential attackers
# @actions : disable unreachables on all interfaces (please refer to engineering/operations guidelines for further information)
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
	unreachables = 0;
',
`/^%SED_BK_JUNI%{2}}$/',`
	if ( unreachables == 1 ) {
		print_err("int_unreachables_notset.juniper-junos.gawk",interface" <unreachables> is set",interfaceno,"high","error");
		pass = 0;
	}
',

dnl ----

`/%SED_BK_JUNI%{3}family inet.* {/',`',
`/^%SED_BK_JUNI%{3}}$/',`',

dnl ----

`/^%SED_BK_JUNI%{4}unreachables/',`unreachables = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_unreachables_notset.juniper-junos.gawk","interface <unreachables> is not set",0,"high","pass");
}

END {
}
