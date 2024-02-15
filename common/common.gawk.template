# -------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# purpose : all the common functions to all tests are put there
# -------------------------------------------------------------

# ----
# generic print error function for cawk
# ----
function print_err(test_name, test_msg, linenu, test_risk, test_status) {
	print FILENAME";"test_name";"test_msg";"linenu";"test_risk";"test_status;
}

# ----
# remove the last char of a string (used for juniper tests for removing <;> character)
# ----
function rm_last_char(str) { 
	return substr(str, 1, length(str)-1) 
}

# ----
# remove the blank character of s tring prefix (used for hierarchical configurations)
# ----
function rm_blank_before(str) { 
	sub(/^ +/, "", str)
	return str
}
