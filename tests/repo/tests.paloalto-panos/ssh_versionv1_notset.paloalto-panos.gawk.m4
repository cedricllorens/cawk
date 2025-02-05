#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <ssh version v1> is not set
# author  : cedric llorens
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

`/^%SED_BK_PALO%{1}system/',`',
`/^%SED_BK_PALO%{1}\}$/',`', 

`/^%SED_BK_PALO%{2}/ && /ssh-version 1/',`
	print_err("ssh_versionv1_notset.paloalto-panos.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("ssh_versionv1_notset.paloalto-panos.gawk","<ssh version 1> is not set",0,"high","pass");
}

END {
}
