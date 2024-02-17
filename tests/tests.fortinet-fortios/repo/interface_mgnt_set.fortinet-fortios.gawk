#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if a management interface is not set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 0 ;
	block_interface = 0;
}

/^config system interface/ {
	block_interface = 1;
	next;
}

/^    edit / && /(management|mgnt)/ && block_interface == 1 {
	print_err("interface_mgnt_noset.fortinet.gawk",rm_blank_before($0),FNR,"high","pass");
	pass = 1;	
	next;
}

/^end$/ {
	block_interface = 0;
}

ENDFILE {
	if ( ! pass ) print_err("interface_mgnt_noset.fortinet.gawk","no mgnt interface is set",0,"high","error");
}

END {
}
