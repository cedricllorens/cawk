#!/usr/bin/env -S gawk -f
# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#

# -------------------------------

function cidrNetworkMask(cidr) {
    prefix_length = int(cidr)
    binary_mask = ""

    for (i = 1; i <= 32; i++) {
        if (i <= prefix_length) {
            binary_mask = binary_mask "1"
        } else {
            binary_mask = binary_mask "0"
        }
    }
    return binary_mask
}

function cidrHostMask(cidr) {
    prefix_length = 32-int(cidr)
    binary_mask = ""

    for (i = 1; i <= prefix_length; i++) {
            binary_mask = binary_mask "1"
    }
    while (length(binary_mask) < 32) {
        binary_mask = "0" binary_mask
    }
    return binary_mask
}

function ipToBinary(ip_address) {
    split(ip_address, octets, ".")
    binary = ""
    for (i = 1; i <= 4; i++) {
        binary = binary decToBin(octets[i])
    }
    return binary
}

function binaryToIP(binary) {
    ip_address = ""
    for (k = 1; k <= length(binary); k = k + 8) {
        octet = substr(binary, k, 8)
	ip_address = ip_address binToDec(octet);
        if (k < length(binary) - 7) {
            ip_address = ip_address "."
        }
    }
    return ip_address
}

function binaryAND(binary1, binary2) {
    result = ""
    for (i = 1; i <= length(binary1); i++) {
        digit1 = substr(binary1, i, 1)
        digit2 = substr(binary2, i, 1)
        if (digit1 == 1 && digit2 == 1) {
            result = result "1"
        } else {
            result = result "0"
        }
    }
    return result
}

function binaryOR(binary1, binary2) {
    result = ""
    for (i = 1; i <= length(binary1); i++) {
        digit1 = substr(binary1, i, 1)
        digit2 = substr(binary2, i, 1)
        if ((digit1 == 1 && digit2 == 0) || (digit1 == 0 && digit2 == 1)) {
            result = result "1"
        } else {
            result = result "0"
        }
    }
    return result
}

function binToDec(binary) {
    decimal = 0
    power = length(binary) - 1
    for (i = 1; i <= length(binary); i++) {
        digit = substr(binary, i, 1)
        decimal += digit * 2^power
        power--
    }
    return decimal
}

function decToBin(decimal) {
    binary = ""
    while (decimal > 0) {
        remainder = decimal % 2
        binary = remainder binary
        decimal = int(decimal / 2)
    }
    while (length(binary) < 8) {
        binary = "0" binary
    }
    return binary
}

function max(x, y) { return (x > y) ? x : y }
function min(x, y) { return (x < y) ? x : y }

# -------------------------------

BEGIN {

    delete cawk_src
    delete cawk_src_orig
    delete cawk_src_net
    delete cawk_dst
    delete cawk_dst_orig
    delete cawk_dst_net
    delete cawk_action
    nbrules = 0

}

/^.*$/ {

	# file format ----------------------------------
	# action     : permit/deny
	# src@       : ip cird/netmask
	# dst@       : ip cird/netmask
	# protocol   : protocol
	# file format ----------------------------------

	nbrules += 1

	cawk_rule_action = $1
	cawk_action[nbrules] = cawk_rule_action

	cawk_src_orig[nbrules] = $2"/"$3
	ip_address = $2
	cidr = $3
 	if ( cidr == "host" ) {
		cawk_src[nbrules] = binToDec(ipToBinary(ip_address))
		cawk_src_net[nbrules] = binToDec(ipToBinary(ip_address))
	} else if ( cird == "any" ) {
		cawk_src[nbrules] = binToDec(ipToBinary("0.0.0.0"))
		cawk_src_net[nbrules] = binToDec(ipToBinary("255.255.255.255"))
	} else {
		cawk_src[nbrules] = binToDec(binaryAND(ipToBinary(ip_address),cidrNetworkMask(cidr)))
		cawk_src_net[nbrules] = binToDec(binaryOR(cidrHostMask(cidr),binaryAND(ipToBinary(ip_address),cidrNetworkMask(cidr))))
	}

	cawk_dst_orig[nbrules] = $4"/"$5
	ip_address = $4
	cidr = $5
 	if ( cidr == "host" ) {
		cawk_dst[nbrules] = binToDec(ipToBinary(ip_address))
		cawk_dst_net[nbrules] = binToDec(ipToBinary(ip_address))
	} else if ( cird == "any" ) {
		cawk_src[nbrules] = binToDec(ipToBinary("0.0.0.0"))
		cawk_src_net[nbrules] = binToDec(ipToBinary("255.255.255.255"))
	} else {
		cawk_dst[nbrules] = binToDec(binaryAND(ipToBinary(ip_address),cidrNetworkMask(cidr)))
		cawk_dst_net[nbrules] = binToDec(binaryOR(cidrHostMask(cidr),binaryAND(ipToBinary(ip_address),cidrNetworkMask(cidr))))
	}
}

END { 
    for(r=1;r<nbrules;r++) {
    	for(s=r;s<nbrules;s++) {

		x_1_0 = cawk_src[r]
        	x_1_1 = cawk_src_net[r]
		y_1_0 = cawk_dst[r]
        	y_1_1 = cawk_dst_net[r]

		x_2_0 = cawk_src[s+1]
        	x_2_1 = cawk_src_net[s+1]
		y_2_0 = cawk_dst[s+1]
        	y_2_1 = cawk_dst_net[s+1]

    		x1 = max(x_1_0,x_2_0)
    		y1 = max(y_1_0,y_2_0)
    		x2 = min(x_1_1,x_2_1)
    		y2 = min(y_1_1,y_2_1)
    
    		if ( x1 <= x2 && y1 <= y2) {
			if ( cawk_action[r] == cawk_action[s+1] ) {
				print "rule "r" with rule "s+1" : rules ip@ have common ip@space / redundant actions"
				print"\trule "r" : ",cawk_action[r],cawk_src_orig[r],cawk_dst_orig[r]
				print"\trule "s+1" : ",cawk_action[s+1],cawk_src_orig[s+1],cawk_dst_orig[s+1]
			} else {
				print "rule "r" with rule "s+1" : rules ip@ have common ip@space / inconsistent actions"
				print"\trule "r" : ",cawk_action[r],cawk_src_orig[r],cawk_dst_orig[r]
				print"\trule "s+1" : ",cawk_action[s+1],cawk_src_orig[s+1],cawk_dst_orig[s+1]
			}
		}
	}
     }
}

