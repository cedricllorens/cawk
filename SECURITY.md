# Security Policy

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please report security issues privately to **cedric.llorens.vdb@gmail.com** with:

- **Subject:** `[SECURITY] cawk vulnerability report`
- **Description:** Detailed explanation of the vulnerability
- **Steps to reproduce:** Clear reproduction steps
- **Impact:** Severity and potential impact
- **Affected versions:** Which cawk versions are impacted
- **Proposed fix** (optional): Any suggestions for remediation

---

## Response Timeline

We will:

1. **Acknowledge** your report within one week
2. **Investigate** and assess the severity
3. **Develop** a fix (timeline depends on severity)
4. **Coordinate** a responsible disclosure and release plan with you
5. **Release** a security update and publish an advisory

For critical vulnerabilities affecting production systems, we aim to provide a fix within 2 weeks.

---

## Supported Versions

We provide security updates for the current and previous minor versions. Older versions are end-of-life.

---

## Security Considerations

### What cawk Does

cawk is a configuration auditing tool that:
- Parses network device configurations from files
- Applies security tests against those configurations
- Generates reports of findings

### Security-Sensitive Areas

When reporting vulnerabilities, pay special attention to:

- **Input validation:** Configuration parsing from untrusted files
- **Regex patterns:** Potential ReDoS (Regular Expression Denial of Service)
- **Shell commands:** Any `system()` calls or shell metacharacters
- **File access:** Permissions, path traversal, symlink attacks
- **Report generation:** Sensitive data leakage or injection

### Out of Scope

The following are typically out of scope:

- Vulnerabilities in third-party dependencies (`gawk`, `make`, `m4`) — report to their maintainers
- Theoretical vulnerabilities with no practical impact
- Social engineering or phishing attacks
- Issues unrelated to cawk itself

---

## Security Best Practices for Users

When using cawk:

1. **Audit the code:** This is open source — review it yourself
2. **Keep updated:** Always use the latest stable version
3. **Sanitize inputs:** Don't feed cawk untrusted configurations without review
4. **Restrict access:** Run cawk on secure, isolated systems when auditing sensitive networks
5. **Report findings:** If you find a vulnerability in your audit targets, report responsibly to the network owner

---

## Attribution

When a security vulnerability is fixed and disclosed, we will:

- Credit the reporter by name or pseudonym (your choice)
- Acknowledge the contribution in release notes
- Link to any public write-ups or CVE records (if applicable)

---

Thank you for helping keep cawk secure.

**cawk is Copyright (C) 2024-2026 by Cedric Llorens**  
**License: MIT** (see [LICENSE](LICENSE))
