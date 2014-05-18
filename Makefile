all:

test:
	$(MAKE) -C test

D = $(DESTDIR)

install:
	install -D -m 755 git-send-series \
		$(D)$(prefix)/bin/git-send-series

.PHONY: all test
