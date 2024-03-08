#!/usr/bin/gawk -f

/.*/ { 
	print "pgm1 "FILENAME,$0;
}
