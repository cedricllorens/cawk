# cawk placeholders (%SED_*)

Reference split from [CLAUDE.md](../CLAUDE.md).

Key `%SED_*` placeholders (defined in `support/tests.sed`):

**Core paths:**
- `%SED_GAWK_PATH%` — shebang path for gawk
- `%SED_INCLUDE_PATH%` — path to `common/common.gawk`
- `%SED_INCLUDE_PATH_FWLIB%` — path to `common/common_hypercube-lib.gawk`

**Block indentation (vendor-specific):**
- `%SED_BK_JUNI%` — block indentation for Juniper Junos
- `%SED_BK_NOKIA%` — block indentation for Nokia SROS
- `%SED_BK_FORTI%` — block indentation for Fortinet FortiOS
- `%SED_BK_PALO%` — block indentation for Palo Alto PAN-OS
- `%SED_BK_WIND%` — block indentation for 6wind-linux

**Authorized admin user patterns (vendor-specific):**
- `%SED_AUTHUSER_CISCO%` — Cisco IOS/XE/XR authorized admin user pattern
- `%SED_AUTHUSER_FORTI%` — Fortinet FortiOS authorized admin user pattern
- `%SED_AUTHUSER_JUNI%` — Juniper Junos authorized admin user pattern
- `%SED_AUTHUSER_NOKIA%` — Nokia SROS authorized admin user pattern
- `%SED_AUTHUSER_CEDGE%` — Cisco Catalyst Edge authorized admin user pattern
- `%SED_AUTHUSER_HUAWEI%` — Huawei VRP authorized admin user pattern
- `%SED_AUTHUSER_VIPTELA%` — Cisco Viptela authorized admin user pattern

**AAA system patterns (vendor-specific):**
- `%SED_AAASYSTEM_JUNI%` — Juniper Junos AAA system patterns
- `%SED_AAASYSTEM_NOKIA%` — Nokia SROS AAA system patterns

**Forbidden protocols (vendor-specific):**
- `%SED_FORBIDPROTO_FORTI%` — Fortinet FortiOS forbidden protocols
- `%SED_FORBIDPROTO_NOKIA%` — Nokia SROS forbidden protocols
- `%SED_FORBIDPROTO_PALO%` — Palo Alto PAN-OS forbidden protocols
- `%SED_FORBIDPROTO_VIPTELA%` — Cisco Viptela forbidden protocols

**Management interface patterns:**
- `%SED_MGNT_KW%` — management interface keywords pattern
- `%SED_MGNT_BADPROTO%` — forbidden protocols for management interfaces

**Security patterns:**
- `%SED_OLD_CRYPTO%` — old/deprecated cryptography patterns
- `%SED_SNMP_FORBID_COMMUNITY%` — SNMP forbidden community strings

