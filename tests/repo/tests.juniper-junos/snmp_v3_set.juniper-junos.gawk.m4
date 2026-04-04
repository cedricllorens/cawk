#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : snmp_v3_set.juniper-junos.gawk
# @supplier : juniper-junos
# @purpose : check if <snmp v3> is set
# @description : missing snmp v3 configuration means secure snmp management with authentication and encryption is not in place
# @actions : configure snmp v3 with authentication and privacy settings (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.6.4 | Ensure SNMPv3 is configured | SNMP
# @authors : cedric llorens
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%
include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 0;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

dnl ----

`/^snmp {$/',`',
`/^}$/',`',

dnl ----

`/%SED_BK_JUNI%v3/',`
	print_err("snmp_v3_set.juniper-junos.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 1;
	nextfile;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
        if ( !pass ) print_err("snmp_v3_set.juniper-junos.gawk","snmp v3 is not set",0,"high","error");
}

END {
}
