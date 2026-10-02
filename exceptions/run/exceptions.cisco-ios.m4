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

dnl @exception_id: EXC-2024-001
dnl @approver: John Doe
dnl @date: 2024-03-15
dnl @reason: Approved firewall policy exception for production environment
dnl m4_cawk_exception(`prod-fw-01',`firewall_acl_policy',`permit 10.0.0.0')

dnl @exception_id: EXC-2024-002
dnl @approver: Jane Smith
dnl @date: 2024-03-20
dnl @reason: Legacy device compatibility with old SSH version
dnl m4_cawk_exception(`legacy-router-01',`ssh_version_check',`SSHv1')

dnl @exception_id: EXC-2026-001
dnl @approver: Test Approver
dnl @date: 2026-08-23
dnl @reason: Validate configurable exception field prefixes and suffixes
dnl m4_cawk_exception_prefixsuffix(`device-01',`test_name',`error message',`0',`1',`1',`0',`0',`1')

dnl MACRO END ------------------------
