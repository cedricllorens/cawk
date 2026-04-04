#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : linevty_transportinputssh_set.cisco-cedge
# @supplier : cisco-cedge
# @purpose : check if a line vty has <transport input ssh>
# @description : vty without restricting transport input to ssh or none allows insecure protocols (telnet) for remote management
# @actions : set <transport input ssh> or <transport input none> on line vty (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.4.3 | Ensure SSH is configured on terminal lines | SSH Access
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

`/^line vty .*$/',`
	linevty = $0;
	linenoaux = FNR;
	transportinputssh = 0;
',
`/^!$/', `
	if ( transportinputssh == 0 ) {
		print_err("linevty_transportinputssh_set.cisco-cedge.gawk",linevty" <transport input ssh> is missing",linenoaux,"high","error");
		pass = 0;
	}
', 

`/^ transport input ssh$/',`transportinputssh = 1;',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("linevty_transportinputssh_set.cisco-cedge.gawk","line vty <transport input ssh> is set",0,"high","pass");
}

END {
}
