#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : linevty_loginauth_set.cisco-cedge.gawk
# @supplier : cisco-cedge
# @purpose : check if a line vty has <login authentication>
# @description : line vty without AAA login authentication can allow unauthorized remote management access without proper credential verification
# @actions : set <login authentication> on line vty with a valid AAA method list (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : IA-2 | Identification and Authentication | Ensure unique identification and authentication of organizational users is configured
# @risk_level : high
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
	linenovty = FNR;
	loginauth = 0;
	transportnone = 0;
',
`/^!$/', `
	if ( loginauth == 0 && transportnone == 0 ) {
		print_err("linevty_loginauth_set.cisco-cedge.gawk",linevty" : login authentication missing",linenovty,"high","error");
		pass = 0;
	}
',

`/^ (login authentication|transport input none)/',`
	if ($0 ~ /^ login authentication/) loginauth = 1;
	if ($0 ~ /^ transport input none$/) transportnone = 1;
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("linevty_loginauth_set.cisco-cedge.gawk","line vty login authentication is set",0,"high","pass");
}

END {
}
