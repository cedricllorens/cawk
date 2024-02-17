#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if a management interface allow forbidden protocols
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1 ;
	block_interface = 0;
	block_edit = 0;
}

/^config system interface/ {
	block_interface = 1;
	next;
}

/^    edit / && /(management|mgnt)/ && block_interface == 1 {
	block_edit = 1;
	block_edit_str = rm_blank_before($0);
	next;
}

/^        [ ]*set allowaccess / && /(telnet|ftp)/ && block_edit == 1 {
	print_err("interface_mgntforbidallow_noset.fortinet.gawk",block_edit_str" "rm_blank_before($0),0,"high","error");
	pass = 0;
	next;
}

/^    next$/ && block_edit == 1 {
	block_edit = 0;
	next;
}

/^end$/ {
	block_edit = 0;
	block_interface = 0;
}

ENDFILE {
	if ( pass ) print_err("interface_mgntforbidallow_noset.fortinet.gawk","mngt interface without forbidden protocols",0,"high","pass");
}

END {
}
