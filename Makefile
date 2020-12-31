prefix := $(HOME)

bindir := $(prefix)/bin
mandir := $(prefix)/share/man/man1
vimdir := $(prefix)/.vim/pack/filetypes/start/gitsendseries

all: doc

doc: doc/git-send-series.1

test:
	$(MAKE) -C test

doc/git-send-series.1: doc/git-send-series.txt
	a2x -d manpage -f manpage $<

clean:
	$(RM) doc/git-send-series.1

D = $(DESTDIR)

install:
	install -D -m 755 git-send-series \
		$(D)$(bindir)/git-send-series

install-doc:
	install -D -m 755 doc/git-send-series.1 \
		$(D)$(mandir)/git-send-series.1

install-vim:
	cp -aT vim $(vimdir)

.PHONY: all test install install-doc install-vim clean
