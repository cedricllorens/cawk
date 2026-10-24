# Docker Check

Test the cawk docker image `cawk-image:v5.0.0` (container `cawk-container-v5.0.0`, volume `cawk-persistent-volume-v5.0.0`, see `Makefile.docker`). Run step by step, stop at the first failure and report where the issue is:

- Version: `gmake version` must print `v5.0.0` (`CAWK_RELEASE` in `support/Makefile.support.mk`).
- Requirements: `gmake -f Makefile.docker check-system` must end with `System: OK` (docker, buildx, `HTTP_PROXY`, `HTTPS_PROXY`).
- Start from a clean state: `gmake -f Makefile.docker clean-all` (container and volume removed, nothing else).
- Build: `gmake -f Makefile.docker build`, then `sudo docker images cawk-image:v5.0.0` must list the image.
- Run: `gmake -f Makefile.docker run`, then wait until `sudo docker logs cawk-container-v5.0.0` shows `Container ready and waiting...` and `sudo docker ps --filter name=cawk-container-v5.0.0` shows `Up`.
- Image content (`sudo docker exec cawk-container-v5.0.0 sh -c "..."`):
  - `whoami` is `appuser`, `gmake --version` and `gawk --version` and `m4 --version` answer.
  - `/app/cawk/docs/logo/logo-cawk.svg` exists.
  - `/app/cawk/{backup,database,exceptions,tests,confs,logs,reports}` are symlinks to `/app/cawk/cawk-persistent-volume/*` and `/app/cawk/tmp` is empty.
- Persistence: `gmake -f Makefile.docker info-volume` shows the volume, `gmake -f Makefile.docker stop` then `gmake -f Makefile.docker run` must keep the data (`ls /app/cawk/cawk-persistent-volume/reports` unchanged).
- Assessment: `gmake -f Makefile.docker cawk-check`, then in the container `tail -n 5 /app/cawk/logs/cawk-check.log` and `/app/cawk/logs/cawk-check_parallel.log` must end with `OK`, `OK` (slow).
- Html report: `sudo docker exec cawk-container-v5.0.0 sh -c "cd /app/cawk && gmake check_repo HTML=yes && grep -c 'data:image' reports/repo/assessment.all.summary.html"` must be at least 1 (logo embedded).
- Report the result of each step; leave the container running unless the user asks for `gmake -f Makefile.docker clean`.
