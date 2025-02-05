#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : check if <lldp> is not set (global)
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

`/^network/',`',
`/^\}$/',`',  

`/^%SED_BK_PALO%{1}[ ]*lldp (enable )?yes/',`
	print_err("int_lldp_notset.paloalto-panos.gawk",rm_blank_before(interface)" "rm_blank_before($0),FNR,"high","error");
	pass = 0;
',
`',`'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_lldp_notset.paloalto-panos.gawk","global <lldp yes> is not set",0,"high","pass");
}

END {
}
