#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if an interface has no <ip directed-broadcast>
# author  : cedric llorens
# @test_name : int_directedbroadcast_notset.cisco-ios.gawk
# @supplier : cisco-ios
# @purpose : check if an interface has no <ip directed-broadcast>
# @description : ip directed-broadcast may trigger attacks
# @actions : set <no ip directed-broadcast> on interfaces (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SI-2 | System and Information Integrity | Ensure flaw remediation and patching is configured
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

dnl level 0 --
`/^interface .*$/',`
	interface = $0;
	interfaceno = FNR;
	directedbroadcast = 0;
',
`/^!$/', `
	if ( directedbroadcast == 1 ) {
		print_err("int_directedbroadcast_notset.cisco-ios.gawk",interface" <ip directed-broadcast> is set",interfaceno,"high","error");
		pass = 0;
	}
', 

dnl level 1 --
`/^ ip directed-broadcast/',`directedbroadcast = 1;',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_directedbroadcast_notset.cisco-ios.gawk","interface <ip directed-broadcast> is not set",0,"high","pass");
}

END {
}
