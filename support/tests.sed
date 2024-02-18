s/%SED_GAWK_PATH%/!\/usr\/bin\/env -S gawk -f/g
s/%SED_INCLUDE_PATH%/"common\/common.gawk"/g
s/%SED_BK_JUNI%/    /g
s/%SED_BK_FORTI%/    /g
s/%SED_BK_NOKIA%/   /g
s/%SED_SNMP_FORBID_COMMUNITY%/(private|public)/g
s/%SED_MGNT_KW%/\(management|mgnt\)/g
s/%SED_MGNT_BADPROTO%/\(telnet|ftp\)/g
