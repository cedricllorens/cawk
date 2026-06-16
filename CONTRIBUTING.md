# Contributing to cawk

Thank you for your interest in contributing to cawk! We welcome bug reports, feature requests, and pull requests.

## Code of Conduct

We are committed to providing a welcoming and inspiring community for all. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting Issues

### Security Issues

If you discover a security vulnerability, please refer to [SECURITY.md](SECURITY.md) for responsible disclosure guidelines.

### Bug Reports

When reporting a bug, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Environment (OS, gawk version, cawk version)
- Configuration files (if applicable, sanitized)

### Feature Requests

Describe the feature, its use case, and any proposed implementation approach.

---

## Pull Request Procedure

### 1. Project Clone

```bash
git clone https://github.com/cedricllorens/cawk.git
cd cawk
```

### 2. Create a Development Branch

Use a descriptive branch name:

```bash
git checkout -b cawk_feature_xyz
# or
git checkout -b cawk_bugfix_123
```

### 3. Make Your Changes

Follow these guidelines:

#### Code Style

- **Language:** All code and comments use **English**
- **Naming:** `lower_snake_case` for functions and variables, `UPPER_SNAKE_CASE` for constants
- **AWK formatting:** Match the style in existing files
- **Comments:** Add only if the logic is non-obvious; avoid stating the obvious
- **Line endings:** Use LF (Unix), not CRLF — `.gitattributes` enforces this

#### File Modifications

Before editing an existing file:
1. Create a `.orig` backup: `cp filename filename.orig`
2. Make your changes
3. Review with `git diff`
4. Run tests (see below)

#### Test Your Changes

- **Template changes:** `gmake tests_repo` or `gmake tests_run`
- **Build system changes:** `gmake check_repo` or `gmake check_run`
- **Database changes:** `gmake catalog_build`
- **Full validation:** `gmake check`

#### Document Your Changes

Update documentation files:
- **README.md** — if a command, option, or feature changes
- **ChangeLog.md** — always, with a brief summary, date (YYYY-MM-DD), and affected files

ChangeLog format:

```markdown
### Fixed
- **2026-06-13** — Brief description of the fix ([affected_file](path/to/file))

### Added
- **2026-06-13** — Brief description of the feature
```

### 4. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git add <specific-files>
git commit -m "Category: Brief summary

Detailed explanation (if needed).

Affected files:
- path/to/file.ext"
```

**Categories:** Fix, Feature, Docs, Build, Refactor, Test, Chore

Example:

```bash
git commit -m "Fix: Normalize line endings in Makefile.cawk.version

Makefile.cawk.version had CRLF endings (likely from Windows editing).
Normalized to LF. Added .gitattributes to enforce LF across all text files.

Affected files:
- Makefile.cawk.version
- .gitattributes
- ChangeLog.md"
```

### 5. Push Your Update

```bash
git push origin cawk_feature_xyz
```

### 6. Create the Pull Request

Visit the GitHub repository and create a pull request from your branch to `main`.

In the PR description:
- Reference related issues (e.g., `Fixes #123`)
- Describe what changed and why
- Mention any testing performed

---

## Local Validation

### Fetch and Checkout a PR Branch

To review or test a PR locally:

```bash
git fetch origin branch_name
git checkout branch_name
```

### Run Checks

```bash
gmake check
```

### Switch Back to Main

```bash
git checkout main
git branch -D branch_name  # Remove local branch if done
```

---

## Update Your Local Repository

```bash
git pull origin main
```

---

## Pre-Submission Checklist

Before pushing, verify:

- [ ] Code compiles without errors (`gmake check_repo`)
- [ ] Tests pass (appropriate test suite)
- [ ] Code style is consistent (naming, formatting, comments)
- [ ] Backup files (`.orig`) exist for modified files
- [ ] Documentation is updated (README.md, ChangeLog.md)
- [ ] Commit messages are clear and descriptive
- [ ] No debug code or commented-out sections left
- [ ] Line endings are LF (not CRLF)

---

## Getting Help

- Check [CLAUDE.md](CLAUDE.md) for detailed technical reference and development practices
- Review recent commits and PRs for examples
- Open an issue to ask questions

---

## License

By contributing to cawk, you agree that your contributions will be licensed under the MIT License. See [LICENSE](LICENSE) for details.

**cawk is Copyright (C) 2024-2026 by Cedric Llorens**
