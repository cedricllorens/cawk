#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : global_lldp_notset.paloalto-panos.gawk
# @supplier : paloalto-panos
# @purpose : check if <lldp> is not set (global)
# @description : lldp enabled globally discloses network topology information to adjacent devices and may be exploited
# @actions : disable lldp globally if not required for network operations (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : AU-12 | Audit and Accountability | Ensure audit record generation is enabled
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

`/^network/',`',
`/^\}$/',`',  

`/^%SED_BK_PALO%{1}[ ]*lldp (enable )?yes/',`
	print_err("global_lldp_notset.paloalto-panos.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("global_lldp_notset.paloalto-panos.gawk","global <lldp yes> is not set",0,"high","pass");
}

END {
}
