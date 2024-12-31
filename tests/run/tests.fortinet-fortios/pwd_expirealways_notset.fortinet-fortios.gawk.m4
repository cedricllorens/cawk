#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : checks if <password-expire = always> is set
# ------------------------------------------------------------

@include %SED_INCLUDE_PATH%

# ----

include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1 ;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

`/^config system admin/', `',
`/^end$/', `',

`/^%SED_BK_FORTI%[ ]*set password-expire/ && /always/', `
	print_err("pwd_expirealways_noset.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;	
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("pwd_expirealways_noset.fortinet-fortios.gawk","<password-expire = always> is not set",0,"high","pass");
}

END {
}
