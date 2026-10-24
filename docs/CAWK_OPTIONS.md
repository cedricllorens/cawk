# cawk global options

Reference split from [CLAUDE.md](../CLAUDE.md).

### Key Configuration: support/Makefile.support.mk

Global options that affect all assessments (defined in `support/Makefile.support.mk`):

| Option | Values | Default | Purpose |
|--------|--------|---------|---------|
| `CAWK_RELEASE` | version string | (varies) | Current cawk release version |
| `MAKE_PARALLEL` | `yes` / `no` | `no` | Spawn multiple make jobs for parallel test execution |
| `MAKE_J` / `MAKE_LOAD_AVG` | number | `nproc` (fallback 4 / 3) | Parallel job count and load-average ceiling when `MAKE_PARALLEL=yes` |
| `MAKE_FILES_PER_TARGET` / `MAKE_FILES_PER_TARGET_PSIRT` | number | 100 / 1 | Config files per target job (standard / PSIRT) |
| `MAKE_FILES_PER_TARGET_MAX` | number | 2000 | Safety ceiling for `MAKE_FILES_PER_TARGET`/`MAKE_FILES_PER_TARGET_PSIRT` (see [CAWK_CODE_RULES.md](docs/CAWK_CODE_RULES.md), `ARG_MAX`) |
| `PSIRT_ONLY` | `yes` / `no` | `no` | Assessment mode: `no` = standard **plus** PSIRT tests; `yes` = PSIRT tests **only** (standard skipped). PSIRT tests are always compiled; this flag only selects which run. |
| `CENSOR_LEVEL` | `internal` / `external` | `internal` | Censor distribution level (`censor_*` targets): `internal` applies the macros of level `internal`, `external` applies those of level `internal` **and** `external`. Any other value is rejected by `check_supplier`. |
| `STANDARD_ONLY` | `yes` / `no` | `no` | Mirror of `PSIRT_ONLY`: `yes` = standard tests **only** (PSIRT skipped). Rejected with `PSIRT_ONLY=yes` (`check_supplier`). |
| `SECRETSCAN` | `yes` / `no` | `no` | `yes`: the final csv reports `assessment.*.csv` are censored (`CENSOR_LEVEL`, the error_line column only, the other columns kept) into `assessment.*.censored.csv` and the originals are removed; the timeline (`*.timeline.censored.csv`) and json (`*.censored.json`) reports are built from the censored csv, `view_*`/`email` read them. `summary.txt`/`summary.json`/`summary.html` hold counters only and are unchanged. Any other value is rejected by `check_supplier` |
| `COLLECT` | `yes` / `no` | `no` | `sync_run audit=...` runs `collect_run` first (a collection failure does not stop the sync, which uses the previously collected confs) |
| `DEADBEEF` | `yes` / `no` | `no` | Flag configs older than threshold |
| `DEADBEEF_THRESHOLD_DAYS` | number | 30 | Days to consider a config "old" |
| `BADFORMAT` | `yes` / `no` | `no` | Exclude badformat configs (first-level indentation violations, detected by `common/badformat_cawk_conf.gawk`) from the final reports; the badformat scan itself always runs |
| `CRLF` | `yes` / `no` | `yes` | Exclude crlf configs (windows format, detected by `common/crlf_cawk_conf.gawk`) from the final reports — forced to `yes` by default since CRLF results are wrong; the crlf scan itself always runs |
| `JSON` | `yes` / `no` | `no` | Generate JSON reports alongside text |
| `TIMELINE` | `yes` / `no` | `yes` | `yes`: write the `assessment.all.*.timeline.csv` reports, the csv they are built from are always kept. `no`: no timeline |
| `HTML` | `yes` / `no` | `yes` | Generate `assessment.all.summary.html` alongside the text reports: standalone high-level page (counters by risk, supplier, NIST control and test, no error line or conf name), built by `common/report_html.gawk` from `common/report_html.skeleton.html` — edit the skeleton for the look, the template for the data. `LOGO_HTML` (default `docs/logo/logo-cawk.svg`) is embedded in the header as a base64 data uri, a missing file means no logo |
| `CATALOG_BUILD` | `yes` / `no` | `no` | Rebuild test catalog (db_info.txt) before assessment |
| `ARCHIVE_OLDER_DAYS` | number | 120 | Auto-cleanup of old report archives |
| `TMP_ASSESSMENT_FILES` | `yes` / `no` | `yes` | Remove intermediate assessment files after reporting |

All options can be overridden per-invocation:

```bash
gmake check_run audit=client1 PSIRT_ONLY=yes JSON=yes DEADBEEF_THRESHOLD_DAYS=180
```
