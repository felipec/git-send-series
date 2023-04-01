prefix := $(HOME)

bindir := $(prefix)/bin
mandir := $(prefix)/share/man/man1
vimdir := $(prefix)/.vim/pack/filetypes/start/gitsendseries

all:

doc: doc/git-send-series.1

test:
	$(MAKE) -C t

%.1: %.adoc
	asciidoctor -b manpage $<

clean:
	$(RM) doc/*.1

D = $(DESTDIR)

install:
	install -D -m 755 git-send-series $(D)$(bindir)/git-send-series

install-doc: doc
	install -D -m 644 doc/git-send-series.1 $(D)$(mandir)/git-send-series.1

install-vim:
	install -d -m 755 $(vimdir)/
	cp -aT vim $(vimdir)/

.PHONY: all doc test install install-doc install-vim clean
