#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : ssh_versionv1_notset.fortinet-fortios.gawk
# @supplier : fortinet-fortios
# @purpose : check if <ssh version 1> is not set
# @description : ssh version 1 has known cryptographic vulnerabilities and must not be used for remote management
# @actions : set ssh version 2 to enforce ssh version 2 only (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.5.2 | Ensure SSH version 2 is used | SSH
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

`/%SED_BK_FORTI%set admin-ssh-.* enable/ && /v1/', `
	print_err("ssh_versionv1_notset.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("ssh_versionv1_notset.fortinet-fortios.gawk","<ssh server> is not set",0,"high","pass");
}

END {
}
