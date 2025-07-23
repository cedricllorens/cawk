dnl ---------------------------------------------------
dnl m4_cawk_exception($1,$2,$3)
dnl  $1 : device name   : extended regex
dnl  $2 : test name     : extended regex
dnl  $3 : error message : extended regex
dnl
dnl m4_cawk_exception(`device100',`',`')
dnl m4_cawk_exception(`',`fw_',`')
dnl m4_cawk_exception(`',`',`ike')
dnl m4_cawk_exception(`device100',`fw_',`ike')
dnl ---------------------------------------------------

include(`cawk.m4')

dnl MACRO BEGIN ------------------------

m4_cawk_exception(`',`aaa_config_set\.cisco-cedge\.gawk',`')

dnl MACRO BEGIN ------------------------
