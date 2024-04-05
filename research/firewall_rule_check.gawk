#!/usr/bin/env -S gawk -f
# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#

@include "firewall_function.include"

# -------------------------------

BEGIN {
	cawk_init_fw_rules()
}

/^.*$/ {

        # file format ----------------------------------
        # action           : permit/deny
        # src@             : ip
        # src_net@         : cird/netmask
        # port_src         : port_src
        # port_src_range   : port_src_range
        # dst@             : ip
        # dst_net@         : cird/netmask
        # port_dst         : port_dst
        # port_dst_range   : port_dst_range
        # protocol         : protocol
        # ----
        # NOTE : set <0> is empty
        # ----
        # file format ----------------------------------

	cawk_add_fw_rules($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
}

END { 
	cawk_fw_rules_assessment()
}

