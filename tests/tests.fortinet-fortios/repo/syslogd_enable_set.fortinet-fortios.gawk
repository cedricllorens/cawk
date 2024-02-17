#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if syslogd is not set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	passglobal = 0;
	passlocal = 0 ;
	block_syslogd = 0;
	block_edit = 0;
}

/^config log syslogd/ {
	block_syslogd = 1;
	block_edit = 0;
	block_edit_str = "";
	passglobal = 1;
	next;
}

/^    edit / && block_syslogd == 1 {
	block_edit = 1;
	block_edit_str = rm_blank_before($0);
	passlocal = 0;
	next;
}

/^        set status enable/ && block_edit == 1 {
	print_err("syslogd_enable_noset.fortinet.gawk",block_edit_str" : syslogd is enable",FNR,"high","pass");
	passlocal = 1;	
	next;
}

/^    next$/ && block_edit == 1 {
	if ( ! passlocal ) print_err("syslogd_enable_noset.fortinet.gawk",block_edit_str" : syslogd is no enable",FNR,"high","error");
	block_edit = 0;
	next;
}

/^end$/ && block_syslogd == 1 {
	block_syslogd = 0;
}

ENDFILE {
	if ( ! passglobal ) print_err("syslogd_enable_noset.fortinet.gawk","syslogd is no set",0,"high","error");
}

END {
}
