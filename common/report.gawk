#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like SED_GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generate a cawk report
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 0;
	error = 0;
	delete files;
	delete tests;
}

/;error$/ {
	split($0,tmp,";");
	files[tmp[1]];
	tests[tmp[2]];
	error += 1;
	next;
}

/;pass$/ {
	split($0,tmp,";");
	files[tmp[1]];
	tests[tmp[2]];
	pass += 1;
	next;
}

ENDFILE {
	print "total number of files " length(files); 
	print "total number of tests " length(tests); 
	for(id in tests) printf("	test %s\n",id);
	if ( ( pass + error ) > 0) print "the number of pass " pass " ("int(100 * pass / ( pass + error))"%)";
	if ( ( pass + error ) > 0) print "the number of error " error " ("int(100 * error / ( pass + error))"%)";
	print "total number of checks " length(files) * length(tests);
}

END {
}
