#!/usr/bin/gawk -f

/.*/ { 
	print "pgm2 "FILENAME,$0;
}
