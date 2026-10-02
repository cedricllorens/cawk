#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_lldp_notset.huawei-vrp.gawk
# @supplier : huawei-vrp
# @purpose : check if an interface has no <lldp enable>
# @description : lldp enabled on interfaces discloses topology information to adjacent devices and may be exploited
# @actions : disable lldp on all interfaces where it is not required (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SC-7 | System and Communications Protection | Ensure boundary protection is configured
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

`/^interface .*$/',`
	interface = $0;
	interfaceno = FNR;
	lldp = 0;
	is_shutdown = 0;
',
`/^\043$/', `
	if ( lldp == 1 && is_shutdown == 0 ) {
		print_err("int_lldp_notset.huawei-vrp.gawk",interface" <lldp enable> is set",interfaceno,"high","error");
		pass = 0;
	}
',

`/^ (lldp enable|shutdown)/',`
	if ($0 ~ /^ lldp enable/) lldp = 1;
	if ($0 ~ /^ shutdown/) is_shutdown = 1;
',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_lldp_notset.huawei-vrp.gawk","interface <lldp enable> is not set",0,"high","pass");
}

END {
}
