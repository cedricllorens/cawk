#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if each user-interface vty has no acl inbound
# ------------------------------------------------------------

@include "common/common.gawk"

# ----

function acl_summary() {
	if ( aclin == 0 ) {
		print_err("userinterfacevty_aclin_set.huawei.gawk",userinterface" : acl inbound missing",userinterfacenovty,"high","error");
		pass = 0;
	}
}

# ----

BEGIN {
}

BEGINFILE {
	block_vty = 0;
	pass = 1;
}

/^user-interface vty .*$/ {
	if ( block_vty == 1 ) acl_summary();
	userinterface = $0;
	userinterfacenovty = FNR;
	aclin = 0;
        block_vty = 1;
	next;
}

/^ acl .* inbound/ && block_vty == 1 {
	aclin = 1;
	next;
}

/^#$/ && block_vty == 1 {
	acl_summary();
	block_vty = 0;
}

ENDFILE {
	if ( pass ) print_err("userinterfacevty_aclin_set.huawei.gawk","user-interface vty acl inbound are set",0,"high","pass");
}

END {
}
