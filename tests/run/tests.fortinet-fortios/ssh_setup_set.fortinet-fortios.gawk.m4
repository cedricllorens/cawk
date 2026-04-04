#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : ssh_setup_set.fortinet-fortios
# @supplier : fortinet-fortios
# @purpose : check if <ssh server> is set
# @description : missing ssh server configuration means secure remote management is not available and the device may fall back to insecure protocols
# @actions : configure ssh server parameters (version, timeout, authentication retries) (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.5.1 | Ensure SSH is enabled | SSH
# @authors : cedric llorens
# ------------------------------------------------------------

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

`/^config system global/', `',
`/^end$/', `',

`/%SED_BK_FORTI%set admin-ssh-.* enable/', `
	print_err("ssh_setup_set.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ssh_setup_set.fortinet-fortios.gawk","<ssh server> is not set",0,"high","error");
}

END {
}
