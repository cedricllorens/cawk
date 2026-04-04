#%SED_GAWK_PATH%

# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : pwd_expirealways_notset.fortinet-fortios
# @supplier : fortinet-fortios
# @purpose : check if <password-expire = always> is not set
# @description : password set to never expire weakens the security posture by allowing indefinitely valid credentials
# @actions : configure password expiration policy (please refer to engineering/operations guidelines for further information)
# @cis_benchmark_ref : 1.2.1 | Ensure password expiration is enforced | Authentication
# @authors : cedric llorens
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
	print_err("pwd_expirealways_notset.fortinet-fortios.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;	
',
`', `'

)

dnl MACRO END --------------------------

ENDFILE {
	if ( pass ) print_err("pwd_expirealways_notset.fortinet-fortios.gawk","<password-expire = always> is not set",0,"high","pass");
}

END {
}
