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

dnl MACRO END ------------------------
