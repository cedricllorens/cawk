# Release Check

Run step by step, stop at the first failure and report where the issue is:

- Save the baseline first: `gmake clean check_repo view_repo > /tmp/release_before.txt` (skip if no change was made since the last save).
- Run `gmake check`; the output must end with `OK`, `OK` (slow).
- Run `gmake check_parallel`; the output must end with `OK`, `OK` (slow).
- Compare with the baseline and explain every difference.
- If all is OK, everything is compliant.
