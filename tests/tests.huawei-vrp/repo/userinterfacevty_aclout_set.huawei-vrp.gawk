#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if each user-interface vty has no acl outbound
# ------------------------------------------------------------

@include "common/common.gawk"

# ----

function acl_summary() {
	if ( aclout == 0 ) {
		print_err("userinterfacevty_aclout_set.huawei.gawk",userinterface" : acl outbound missing",userinterfacenovty,"high","error");
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
	aclout = 0;
        block_vty = 1;
	next;
}

/^ acl .* outbound/ && block_vty == 1 {
	aclout = 1;
	next;
}

/^#$/ && block_vty == 1 {
	acl_summary();
	block_vty = 0;
}

ENDFILE {
	if ( pass ) print_err("userinterfacevty_aclout_set.huawei.gawk","user-interface vty acl outbound are set",0,"high","pass");
}

END {
}
