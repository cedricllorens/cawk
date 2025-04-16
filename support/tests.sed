# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#
# ----------------------------------------------
# GENERIC SYSTEM RULES
# ----------------------------------------------
s/%SED_GAWK_PATH%/!\/usr\/bin\/env -S gawk -f/g
s/%SED_INCLUDE_PATH%/"common\/common.gawk"/g
s/%SED_INCLUDE_PATH_FWLIB%/"common\/common.fwlib.gawk"/g
#
# ----------------------------------------------
# CISCO
# ----------------------------------------------
s/%SED_AUTHUSER_CISCO%/\(admin\)/g
#
# ----------------------------------------------
# CISCO_CEDGE
# ----------------------------------------------
s/%SED_AUTHUSER_CEDGE%/\(admin\)/g
#
# ----------------------------------------------
# CISCO_VIPTELA
# ----------------------------------------------
s/%SED_AUTHUSER_VIPTELA%/\(admin\)/g
s/%SED_FORBIDPROTO_VIPTELA%/\(http|telnet|ftp|lldp|cdp\)/g
#
# ----------------------------------------------
# HUAWEI
# ----------------------------------------------
s/%SED_AUTHUSER_HUAWEI%/\(admin\)/g
#
# ----------------------------------------------
# JUNIPER
# ----------------------------------------------
s/%SED_BK_JUNI%/([ ][ ][ ][ ])/g
s/%SED_AUTHUSER_JUNI%/admin/g
s/%SED_AAASYSTEM_JUNI%/(tacacs|tacplus|radius)/g
#
# ----------------------------------------------
# FORTINET
# ----------------------------------------------
s/%SED_BK_FORTI%/([ ][ ][ ][ ])/g
s/%SED_AUTHUSER_FORTI%/\"admin\"/g
s/%SED_FORBIDPROTO_FORTI%/\"(HTTP|TELNET|FTP|LLDP|CDP)\"/g
#
# ----------------------------------------------
# NOKIA
# ----------------------------------------------
s/%SED_BK_NOKIA%/([ ][ ][ ][ ])/g
s/%SED_AUTHUSER_NOKIA%/\("admin"\)/g
s/%SED_AAASYSTEM_NOKIA%/(tacplus|radius)/g
s/%SED_FORBIDPROTO_NOKIA%/(http|telnet|ftp|lldp|cdp)/g
#
# ----------------------------------------------
# PALOALTO
# ----------------------------------------------
s/%SED_BK_PALO%/([ ][ ])/g
s/%SED_FORBIDPROTO_PALO%/(web|telnet|ftp|lldp|cdp)/g
#
# ----------------------------------------------
# CHECKPOINT
# ----------------------------------------------
#
# ----------------------------------------------
# PACKETFILTER
# ----------------------------------------------
#
# ----------------------------------------------
# IPTABLES
# ----------------------------------------------
#
# ----------------------------------------------
# 6WIND
# ----------------------------------------------
s/%SED_BK_WIND%/([ ][ ][ ][ ])/g
#
# ----------------------------------------------
# GENERIC SYSTEM RULES
# ----------------------------------------------
s/%SED_SNMP_FORBID_COMMUNITY%/(private|public)/g
s/%SED_MGNT_KW%/\(management|mgnt\)/g
s/%SED_MGNT_BADPROTO%/\(http|telnet|ftp\)/g
