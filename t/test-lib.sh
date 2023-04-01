#!/bin/sh

. "$(dirname "$0")"/sharness.sh

cat > "$HOME/.gitconfig" <<-EOF
[user]
	name = Author
	email = author@example.com
EOF

test_cmp() {
	${TEST_CMP:-diff -u} "$@"
}

test_when_finished() {
	test_cleanup="{ $*
		} && (exit \"\$eval_ret\"); eval_ret=\$?; $test_cleanup"
}

test_must_fail() {
	"$@"
	exit_code=$?
	if test $exit_code = 0; then
		echo >&2 "test_must_fail: command succeeded: $*"
		return 1
	elif test $exit_code -gt 129 -a $exit_code -le 192; then
		echo >&2 "test_must_fail: died by signal: $*"
		return 1
	elif test $exit_code = 127; then
		echo >&2 "test_must_fail: command not found: $*"
		return 1
	fi
	return 0
}
