#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if ikev1 is set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1 ;
	block_ipsec = 0;
}

/^config vpn ipsec/ {
	block_ipsec = 1;
	next;
}

/^    [ ]*(set version v1|ikev1)/ && block_ipsec == 1 {
	print_err("ipsec_ikev1_noset.fortinet.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;	
	next;
}

/^end$/ {
	block_interface = 0;
}

ENDFILE {
	if ( pass ) print_err("ipsec_ikev1_noset.fortinet.gawk","ikev1 is not set",0,"high","pass");
}

END {
}
