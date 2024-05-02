#!/usr/bin/env -S gawk -f
# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#

# file format ----------------------------------
# action           : permit/deny
# src@             : ip
# src_net@         : cird/netmask
# port_src         : port_src		set 0 if empty
# port_src_range   : port_src_range	set 0 if empty
# dst@             : ip			set 0 if empty
# dst_net@         : cird/netmask	set 0 if empty
# port_dst         : port_dst		set 0 if empty
# port_dst_range   : port_dst_range	set 0 if empty
# protocol         : protocol		set none if empty
# file format ----------------------------------

@include "firewall_function.include"

BEGIN {
}

BEGINFILE {
	cawk_init_fw_rules();
	block_acl = 0;
	acl = "";
}

/^ip access-list standard [^ ]+$/ {
	acl = $4;
	block_acl = 1;
}

/^[ ]([0-9]+ )?(permit|deny) ([0-9\.]+ [0-9\.]+|any)$/ && block_acl == 1 {
	cawk_add_fw_rules("fw_acl-std-check_cisco-ios.gawk","access-list "acl,$2,$3,$4,0,0,0,0,0,0,none)
}

/^(!|end)$/ && block_acl == 1 {
	if ( cawk_fw_rules_assessment() ) {
		print_err("fw_acl-std-check_cisco-ios.gawk","access-list "acl" has no redundant/inconsistent rules",FNR,"high","pass");
	}
	cawk_init_fw_rules();
	block_acl = 0;
	acl = "";
}

ENDFILE { 
}
