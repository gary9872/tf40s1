# $Id: unix.mak,v 35004.22 1999/01/31 00:28:10 hawkeye Exp $
########################################################################
#  TinyFugue - programmable mud client
#  Copyright (C) 1994 - 1999 Ken Keys
#
#  TinyFugue (aka "tf") is protected under the terms of the GNU
#  General Public License.  See the file "COPYING" for details.
#
#  DO NOT EDIT THIS FILE.
#  Any configuration changes should be made to the Config file.
########################################################################

#
# unix section of src/Makefile.
#

#CFLAGS     = $(FLAGS)
SHELL      = /bin/sh
BUILDERS   = Makefile


install:  _failmsg _all $(TF) LIBRARY $(MANPAGE) $(SYMLINK)
	@echo '#####################################################' > exitmsg
	@echo '## TinyFugue installation successful.' >> exitmsg
	@echo "## You can safely delete everything in `cd ..; pwd`". >> exitmsg
	@DIR=`echo $(TF) | sed 's;/[^/]*$$;;'`; \
	echo ":$(PATH):" | egrep ":$${DIR}:" >/dev/null 2>&1 || { \
	    echo ; \
	} >> exitmsg

all files:  _all
	@echo '#####################################################' > exitmsg
	@echo '## TinyFugue build successful.' >> exitmsg
	@echo '## Use "unixmake install" to install the files.' >> exitmsg

_all:  tf$(X) ../tf-lib/tf-help.idx

_failmsg:
	@echo '#####################################################' > exitmsg
	@echo '#### TinyFugue installation FAILED.' >> exitmsg
	@echo '#### See README for help.' >> exitmsg
	@if [ "$(CC)" = "gcc" ]; then \
	    echo '#### '; \
	    echo '#### Perhaps $(CC) is not configured correctly.'; \
	    echo '#### Before contacting the author, set (and uncomment)'; \
	    echo '#### CC=cc in unix/Config and try again.'; \
	fi >> exitmsg

regexp.o: $(BUILDERS) config.h
	cd ./regexp; \
	    $(MAKE) CC='$(CC)' CFLAGS='$(CFLAGS)' O=o regexp.o >err 2>&1 || \
	    { cat err; rm err; exit 1; }
	rm regexp/err
	mv regexp/regexp.o .

TF tf$(X):     $(OBJS) $(BUILDERS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o tf$(X) $(OBJS) $(LIBS)
#	@# Some stupid linkers return ok status even if they fail.
	@test -f tf$(X)
#	@# ULTRIX's sh errors here if strip isn't found, despite "true".
	-test -z "$(STRIP)" || $(STRIP) tf$(X) || true

install_TF $(TF): tf$(X) $(BUILDERS)
	-@rm -f $(TF)
	cp tf$(X) $(TF)
	chmod $(MODE) $(TF)

SYMLINK $(SYMLINK): $(TF)
	test -z "$(SYMLINK)" || { rm -f $(SYMLINK) && ln -s $(TF) $(SYMLINK); }

LIBRARY $(LIBDIR): ../tf-lib/tf-help ../tf-lib/tf-help.idx
	@echo '## Creating library directory...'
#	@# Overly simplified shell commands, to avoid problems on ultrix
	-@test -n "$(LIBDIR)" || echo "LIBDIR is undefined.  Check unix/Config."
	test -n "$(LIBDIR)"
	test -d "$(LIBDIR)" || mkdir $(LIBDIR)
	-@test -d "$(LIBDIR)" || echo "Can't make $(LIBDIR) directory.  See if"
	-@test -d "$(LIBDIR)" || echo "there is already a file with that name."
	test -d "$(LIBDIR)"
#
#	@#rm -f $(LIBDIR)/*;  # wrong: this would remove local.tf, etc.
	@echo '## Copying library files...'
	cd ../tf-lib; \
	for f in *; do test -f $$f && files="$$files $$f"; done; \
	( cd $(LIBDIR); rm -f $$files tf.help tf.help.index; ); \
	cp $$files $(LIBDIR); \
	cd $(LIBDIR); \
	chmod $(MODE) $$files; chmod ugo-wx $$files
	-rm -f $(LIBDIR)/CHANGES 
	cp ../CHANGES $(LIBDIR)
	chmod $(MODE) $(LIBDIR)/CHANGES; chmod ugo-wx $(LIBDIR)/CHANGES
	chmod $(MODE) $(LIBDIR)
	-@cd $(LIBDIR); old=`ls replace.tf 2>/dev/null`; \
	if [ -n "$$old" ]; then \
	    echo "## WARNING: Obsolete files found in $(LIBDIR): $$old"; \
	fi
	@echo '## Creating links so old library names still work...'
#	@# note: ln -sf isn't portable.
	@cd $(LIBDIR); \
	rm -f bind-bash.tf;    ln -s  kb-bash.tf   bind-bash.tf;    \
	rm -f bind-emacs.tf;   ln -s  kb-emacs.tf  bind-emacs.tf;   \
	rm -f completion.tf;   ln -s  complete.tf  completion.tf;   \
	rm -f factorial.tf;    ln -s  factoral.tf  factorial.tf;    \
	rm -f file-xfer.tf;    ln -s  filexfer.tf  file-xfer.tf;    \
	rm -f local.tf.sample; ln -s  local-eg.tf  local.tf.sample; \
	rm -f pref-shell.tf;   ln -s  psh.tf       pref-shell.tf;   \
	rm -f space_page.tf;   ln -s  spc-page.tf  space_page.tf;   \
	rm -f speedwalk.tf;    ln -s  spedwalk.tf  speedwalk.tf;    \
	rm -f stack_queue.tf;  ln -s  stack-q.tf   stack_queue.tf;  \
	rm -f worldqueue.tf;   ln -s  world-q.tf   worldqueue.tf;

makehelp: makehelp.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o makehelp makehelp.c

__always__:

../tf-lib/tf-help: __always__
	if test -d ../help; then cd ../help; $(MAKE) tf-help; fi
	if test -d ../help; then cp ../help/tf-help ../tf-lib; fi

../tf-lib/tf-help.idx: ../tf-lib/tf-help makehelp
	$(MAKE) -f ../unix/unix.mak CC='$(CC)' CFLAGS='$(FLAGS)' makehelp
	./makehelp < ../tf-lib/tf-help > ../tf-lib/tf-help.idx

MANPAGE $(MANPAGE): $(BUILDERS) tf.1.$(MANTYPE)man
	cp tf.1.$(MANTYPE)man $(MANPAGE)
	chmod $(MODE) $(MANPAGE)
	chmod ugo-x $(MANPAGE)

tf.1.catman:  tf.1.nroffman
	TERM=vt100; nroff -man tf.1.nroffman > tf.1.catman

Makefile: ../unix/Config ../unix/vars.mak ../unix/unix.mak ../unix/tfconfig
	@echo
	@echo "## WARNING: changes in Config, etc. will not be reflected."
	@echo

dist: tf.1.catman ../tf-lib/tf-help.idx

uninstall:
	@echo "Remove $(LIBDIR) $(TF) $(MANPAGE)"
	@echo "Is this okay? (y/n)"
	@read response; test "$$response" = "y"
	rm -f $(TF) $(MANPAGE)
	rm -rf $(LIBDIR)

clean distclean cleanest:
	cd ..; ./unixmake $@


# development stuff, not necessarily portable.

tags: *.[ch]
	ctags port.h tf.h *.[ch] 2>/dev/null

dep: *.c
	gcc -E -MM *.c \
		| sed 's;regexp/regexp.h ;;' \
		| sed 's; $$; $$(BUILDERS) ;' \
		> dep

tf.pixie: tf$(X)
	pixie -o tf.pixie tf$(X)

lint:
	lint -woff 128 $(CCFLAGS) -DHAVE_PROTOTYPES $(SOURCE) $(LIBRARIES)

# The next line is a hack to get around a bug in BSD/386 make.
make:

