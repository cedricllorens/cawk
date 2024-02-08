# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# purpose : all the common functions to all tests are put there
# ------------------------------------------------------------

function print_err(test_name, test_msg, linenu, test_risk, test_status) {
	print FILENAME";"test_name";"test_msg";"linenu";"test_risk";"test_status;
}
