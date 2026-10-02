dnl ---------------------------------------------------
dnl This macro is used to generate an exception
dnl m4_cawk_exception($1,$2,$3)
dnl  $1 : device name   : extended regex
dnl  $2 : test name     : extended regex
dnl  $3 : error message : extended regex
dnl ---------------------------------------------------

dnl ---------------------------------------------------
dnl This macro is used to generate an exception
dnl m4_cawk_exception_prefixsuffix($1,$2,$3,$4,$5,$6,$7,$8,$9)
dnl  $1 : device name   : extended regex
dnl  $2 : test name     : extended regex
dnl  $3 : error message : extended regex
dnl  $4 : prefix for device name   : default 1=add [^;]* , 0=no prefix
dnl  $5 : suffix for device name   : default 1=add [^;]* , 0=no suffix
dnl  $6 : prefix for test name     : default 1=add [^;]* , 0=no prefix
dnl  $7 : suffix for test name     : default 1=add [^;]* , 0=no suffix
dnl  $8 : prefix for error message : default 1=add [^;]* , 0=no prefix
dnl  $9 : suffix for error message : default 1=add [^;]* , 0=no suffix
dnl ---------------------------------------------------

include(`cawk.m4')

dnl MACRO BEGIN ------------------------

dnl @exception_id: EXC-001
dnl @approver: Name
dnl @date: YYYY-MM-DD
dnl @reason: Brief business context
dnl m4_cawk_exception_prefixsuffix(`',`global_forbidservices_notset.6wind-linux.gawk',`',`1',`1',`1',`1',`1',`1')
dnl m4_cawk_exception_prefixsuffix(`',`test_test_notset.6wind-linux.gawk',`',`1',`1',`1',`1',`1',`1')

dnl @exception_id: EXC-002
dnl @approver: Name
dnl @date: YYYY-MM-DD
dnl @reason: Brief business context
dnl m4_cawk_exception(`device',`test_name',`pattern')
dnl m4_cawk_exception(`',`test1_test1_notset.6wind-linux.gawk',`')
dnl m4_cawk_exception_prefixsuffix(`',`test2_test2_notset.6wind-linux.gawk',`',`1',`1',`1',`1',`1',`1')

dnl MACRO END ------------------------
