#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : ssh_setup_set.cisco-viptela
# @supplier : cisco-viptela
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
	pass = 0;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

dnl level 0 --
`/^system$/',`',
`/^!$/', `',

dnl level 2 --
`/ssh-server/',`
	print_err("ssh_setup_set.cisco-viptela.gawk",$0,FNR,"high","pass");
	pass = 1;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( ! pass ) print_err("ssh_setup_set.cisco-viptela.gawk","<ssh server> is not set",0,"high","error");
}

END {
}
