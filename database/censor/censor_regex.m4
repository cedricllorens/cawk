dnl ------------------------------------------------------------
dnl cawk is subject to a MIT open-source licence
dnl please refer to the MIT licence file for further information
dnl
dnl patterns used by common/censor.gawk (gmake censor_repo / censor_run)
dnl
dnl compiled by gmake (m4 -I m4, empty lines removed) into database/censor/censor_regex :
dnl one gawk rule per macro (regex constants, compiled once), applied in order on every line of the configurations
dnl
dnl commands of m4/cawk_censor.m4, the first argument is an extended regex (gawk), they are not nested :
dnl   censor_after(`regex')  : the text following the regex is censored
dnl                            snmp-server community public RO  ->  snmp-server community CENSORED
dnl   censor_match(`regex')  : the text matched by the regex is censored, so the regex must cover the value
dnl                            password +[^ ]+ : enable password 7 0822455D0A16  ->  enable CENSORED 0822455D0A16
dnl   censor_line(`regex')   : the whole line containing a match of the regex is censored
dnl                            never surround the regex with .* (the macro already tests the whole line, a leading .* is ~87x slower)
dnl   censor_ignore(`regex') : like censor_match, the case is ignored
dnl optional second argument : `lowercaseuppercase' ignores the case of the regex, e.g. censor_after(` password ', `lowercaseuppercase')
dnl optional third argument : the level of the regex, internal (default) or external, e.g. censor_match(`ip address [0-9.]+', `', `external')
dnl optional fourth argument : the word printed in place of the censored text, CENSORED by default, e.g. censor_match(`password +[^ ]+', `', `internal', `XXXX')
dnl   internal : applied by every censoring (gmake CENSOR_LEVEL=internal, the default, and CENSOR_LEVEL=external)
dnl   external : applied only by gmake censor_* CENSOR_LEVEL=external (distribution outside of the company)
dnl ------------------------------------------------------------
include(`cawk_censor.m4')dnl

dnl one regex per section, line by line ; the case is ignored (lowercaseuppercase), the level is internal unless stated

dnl ADMIN SECTION ---------------------------------------
censor_after(` (access-class |transport (input|output) |trusthost[0-9]* )',`lowercaseuppercase',`internal',`CENSORED')

dnl AUTHENTICATION SECTION ---------------------------------------
censor_after(`(aaa (authentication |accounting | authorization )|user(name)? |local-user |(tacacs|radius|ldap)-server )',`lowercaseuppercase',`internal',`CENSORED')

dnl CRYPTO SECTION ---------------------------------------
censor_after(`(ip ssh |crypto isakmp key |(ssh-(rsa|dsa|ecdsa|ed25519)|ecdsa-sha2-[a-z0-9]+) )',`lowercaseuppercase',`internal',`CENSORED')

dnl SECRET SECTION ---------------------------------------
dnl hash formats (md5 $1$, sha256 $5$, sha512 $6$, cisco $8$ $9$, juniper $9$, yescrypt $y$, bcrypt $2a$) and check point grub2 pbkdf2, whatever the keyword, URL credentials scheme://user:pass@
censor_match(`\$(1|5|6|8|9|y|2[abxy])\$[^ ;"]+|[a-z][a-z0-9+.-]*:[/][/][^ /:@]+:[^ /@]+@|grub\.pbkdf2\.sha512\.[^ ;"]+|service password-encryption',`lowercaseuppercase',`internal',`CENSORED')
censor_after(`( pwd | passwd | password | passphrase | secret | psksecret | key( |_|-)| enc(rypt|rypted|ryption)? | (authentication-|message-digest-|pre-shared-|privacy-|priv-|auth-|secret-|shared-|private-|api-|expert-|grub2-)?(key|password)(-string|-hash)? | phash | key-string | (encrypted|simple)-password | (auth|priv)(password|-pwd|-pass|pwd) | psk | wpa-psk | wpa-passphrase | set-key | bind-password | bind-pw | standby +[0-9]+ authentication +| glbp +[0-9]+ authentication( +text)? +| authentication hash2? | irreversible-cipher | cipher )',`lowercaseuppercase',`internal',`CENSORED')

dnl MONITORING SECTION -----------------------------------
censor_after(`(snmp-server +[^ ]+|snmp-agent community +(read|write) +|snmp +(community|trap-group) |snmp[ _-]?(set-(read|write)-community|(trap[-_ ]?)?community)[^ =]*=? ?|^ +community |(ro|rw)community +|createUser +[^ ]+ +|notification-type +[A-Za-z0-9]+ +community )',`lowercaseuppercase',`internal',`CENSORED')

dnl CERTIFICATE SECTION ---------------------------------------
censor_line(`BEGIN [A-Z ]*(PRIVATE KEY|CERTIFICATE)|[0-9A-Fa-f]{8}( [0-9A-Fa-f]{8}){3,}',`',`internal',`CENSORED')

dnl IDENTITY SECTION ---------------------------------------
censor_after(`(hostname |host-name |sysname |domain-name |domain-list |description |contact |location )',`lowercaseuppercase',`external',`CENSORED')

dnl TOPOLOGY SECTION ---------------------------------------
dnl IPv4, IPv6 and MAC addresses (aa:bb:cc:dd:ee:ff, aa-bb-cc-dd-ee-ff, aaaa.bbbb.cccc), netmasks included
censor_match(`([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{0,4}|([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}|([0-9a-fA-F]{4}\.){2}[0-9a-fA-F]{4}',`',`external',`CENSORED')
