# usage: gawk -v t=<word> -f similar_target.awk  (stdin: output of gmake -pRrq)
# prints at most 5 known targets close to t: substring first, then Levenshtein distance <= 2, closest first
function lev(a, b,   la, lb, i, j, c, m, p, q, d) {
	la = length(a); lb = length(b)
	for (j = 0; j <= lb; j++) p[j] = j
	for (i = 1; i <= la; i++) {
		q[0] = i
		for (j = 1; j <= lb; j++) {
			c = (substr(a, i, 1) == substr(b, j, 1)) ? 0 : 1
			m = p[j - 1] + c
			if (p[j] + 1 < m) m = p[j] + 1
			if (q[j - 1] + 1 < m) m = q[j - 1] + 1
			q[j] = m
		}
		for (j = 0; j <= lb; j++) p[j] = q[j]
	}
	return p[lb]
}
/^[a-zA-Z0-9_]+:/ {
	n = $0; sub(/:.*/, "", n)
	if (n in seen) next
	seen[n] = 1
	if (index(n, t)) score[n] = 0
	else { d = lev(n, t); if (d <= 2 && length(t) >= 3) score[n] = d }
}
END {
	for (lvl = 0; lvl <= 2; lvl++)
		for (n in score) if (score[n] == lvl && shown < 5) { out = out (out == "" ? "" : ", ") n; shown++ }
	print out
}
