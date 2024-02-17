#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generate an error when an acl is def and not ref
# purpose : this test generate an error when an acl is ref and not def
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1;
	delete acl_def;
	delete acl_ref;
}

# def ----

/^acl number [^ ]+$/ {
	acl_def[$NF] = $0;
	next;
}

# ref ----

/^ acl [^ ]+ (inbound|outbound)$/ {
	acl_ref[$2] = $0;
	next;
}

/^ packet-filter inbound acl [^ ]+$/ {
	acl_ref[$NF] = $0;
}

ENDFILE {

	# acl def not ref ----
	for (id in acl_def) {
		if ( !(id in acl_ref) ) {
			print_err("acl_defref_set.huawei.gawk",id" : acl def but not ref :"acl_def[id],0,"low","error");
			pass = 0;
		}
	}

	# acl ref not def ----
	for (id in acl_ref) {
		if ( !(id in acl_def) ) {
			print_err("acl_defref_set.huawei.gawk",id" : acl ref but not def :"acl_ref[id],0,"high","error");
			pass = 0;
		}
	}

	if ( pass ) print_err("acl_defref_set.huawei.gawk","all acls defs are refs and the reverse",0,"high","pass");
}

END {
}
