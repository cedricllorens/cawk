#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like SED_GAWK_PATH, etc. please refer to 
# file support/tests.sed for further information
#
# @test_name : snmp_v3host_set.cisco-viptela.gawk
# @supplier : cisco-viptela
# @purpose : check if <snmp v3 host> is set
# @description : missing snmp v3 trap host configuration means security events and traps may not be forwarded to the monitoring system
# @actions : set <snmp-server host> with snmp v3 credentials pointing to the monitoring trap receiver (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SI-2 | System and Information Integrity | Ensure flaw remediation and patching is configured
# @risk_level : high
# @authors : cedric llorens
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%
include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

dnl level 0 --
`/^snmp/',`',
`/^!$/', `',

dnl level 1 --
`/^ trap(s)?$/',`',
`', `',

dnl level 2 --
`/^[ ][ ]host /',`
	print_err("snmp_v3host_set.cisco-viptela.gawk","snmp v3 host is set : "$0,FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("snmp_v3host_set.cisco-viptela.gawk","snmp v3 host is not set",0,"high","error");
}

END {
}
