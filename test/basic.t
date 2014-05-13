#!/bin/sh

#
# Copyright (C) 2014 Felipe Contreras
#
# This file may be used under the terms of the GNU GPL version 2.
#

test_description='Test basic functionality'

. ./sharness.sh

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
	do_commit three
'

test_expect_success 'simple send' '
	test_when_finished "rm -f actual" &&
	mkdir -p .git/series/ &&
	cat > .git/series/topic <<-\EOF &&
	version: 1

	Summary

	Description.
	EOF
	git send-series &&
	cat > expected <<-EOF &&
	Subject: [PATCH v1 0/3] Summary
	Subject: [PATCH v1 1/3] one
	Subject: [PATCH v1 2/3] two
	Subject: [PATCH v1 3/3] three
	EOF
	test_cmp expected actual
'

test_expect_success 'edit and send' '
	test_when_finished "rm -f actual" &&
	cat > editor <<-\EOS &&
		#!/bin/sh
		cat > "$1" <<EOF
		version: 2

		Summary

		Description.
		EOF
	EOS
	chmod +x editor &&
	EDITOR=./editor git send-series &&
	cat > expected <<-EOF &&
	Subject: [PATCH v2 0/3] Summary
	Subject: [PATCH v2 1/3] one
	Subject: [PATCH v2 2/3] two
	Subject: [PATCH v2 3/3] three
	EOF
	test_cmp expected actual
'

test_expect_success 'cancel edit' '
	test_when_finished "rm -f actual" &&
	cat > editor <<-\EOS &&
		#!/bin/sh
		> "$1"
	EOS
	chmod +x editor &&
	test_must_fail env EDITOR=./editor git send-series &&
	test -s .git/series/topic
'

test_done
