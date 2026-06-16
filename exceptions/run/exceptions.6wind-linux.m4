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

dnl @exception_id: EXC-001
dnl @approver: Name
dnl @date: YYYY-MM-DD
dnl @reason: Brief business context
m4_cawk_exception(`',`global_forbidservices_notset.6wind-linux.gawk',`')

dnl @exception_id: EXC-002
dnl @approver: Name
dnl @date: YYYY-MM-DD
dnl @reason: Brief business context
dnl m4_cawk_exception(`device',`test_name',`pattern')

dnl MACRO END ------------------------
