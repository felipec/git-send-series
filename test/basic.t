#!/bin/sh

#
# Copyright (C) 2014 Felipe Contreras
#
# This file may be used under the terms of the GNU GPL version 2.
#

test_description='Test basic functionality'

. ./test-lib.sh

EDITOR=true

do_commit () {
	local filename="$1"
	echo "${2-$filename}" > "$filename" &&
	git add "$filename" &&
	git commit -q -m "$filename"
}

test_expect_success 'setup' '
	cat > sendmail <<-\EOF &&
	grep "^Subject: " >> actual
	EOF
	chmod +x sendmail &&
	git init -q &&
	git config sendemail.to foo@bar.com &&
	git config sendemail.smtpserver "$HOME"/sendmail &&
	git config sendemail.confirm never &&
	do_commit base &&
	git checkout --track -b topic &&
	do_commit one &&
	do_commit two &&
	do_commit three &&
	mkdir -p .git/series/
'

test_expect_success 'simple send' '
	cat > .git/series/topic <<-\EOF &&
	version: 1

	Summary

	Description.
	EOF
	> actual &&
	git send-series &&
	test_when_finished "git update-ref -d refs/sent/topic/v1" &&
	cat > expected <<-EOF &&
	Subject: [PATCH v1 0/3] Summary
	Subject: [PATCH v1 1/3] one
	Subject: [PATCH v1 2/3] two
	Subject: [PATCH v1 3/3] three
	EOF
	test_cmp expected actual
'

test_expect_success 'edit and send' '
	cat > editor <<-\EOS &&
		#!/bin/sh
		cat > "$1" <<EOF
		version: 2

		Summary

		Description.
		EOF
	EOS
	chmod +x editor &&
	> actual &&
	EDITOR=./editor git send-series &&
	test_when_finished "git update-ref -d refs/sent/topic/v2" &&
	cat > expected <<-EOF &&
	Subject: [PATCH v2 0/3] Summary
	Subject: [PATCH v2 1/3] one
	Subject: [PATCH v2 2/3] two
	Subject: [PATCH v2 3/3] three
	EOF
	test_cmp expected actual
'

test_expect_success 'cancel edit' '
	cat > editor <<-\EOS &&
		#!/bin/sh
		> "$1"
	EOS
	chmod +x editor &&
	test_must_fail env EDITOR=./editor git send-series &&
	test -s .git/series/topic &&
	test_must_fail env EDITOR=false git send-series
'

test_expect_success 'multiple send' '
	cat > .git/series/topic <<-\EOF &&
	version:

	Summary

	Description.
	EOF
	git send-series &&
	test_when_finished "git update-ref -d refs/sent/topic/v1" &&

	do_commit four &&
	test_must_fail git send-series &&

	sed -i "s/version: 1/version: 2/" .git/series/topic &&
	> actual &&
	git send-series &&
	test_when_finished "git update-ref -d refs/sent/topic/v2" &&
	cat > expected <<-EOF &&
	Subject: [PATCH v2 0/4] Summary
	Subject: [PATCH v2 1/4] one
	Subject: [PATCH v2 2/4] two
	Subject: [PATCH v2 3/4] three
	Subject: [PATCH v2 4/4] four
	EOF
	test_cmp expected actual
'

test_expect_success 'no upstream error' '
	git checkout -b bad-topic &&
	test_when_finished "rm -f actual" &&
	test_must_fail git send-series
'

test_done
