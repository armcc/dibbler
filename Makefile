include Makefile.inc
PREFIX = .
export TOPDIR=$(CURDIR)

all: server client relay

includes:
	cd $(INCDIR); $(MAKE) links

bison: bison/bison++

bison/bison++:
	@echo "[CONFIG ] /bison++/"
	cd $(PREFIX)/bison++; ./configure >configure.log
	@echo "[MAKE   ] /bison++/bison++"
	$(MAKE) -C $(PREFIX)/bison++

parser: 
	$(MAKE) -C $(CLNTCFGMGR) parser
	$(MAKE) -C $(SRVCFGMGR) parser
	$(MAKE) -C $(RELCFGMGR) parser

client: $(CLIENTBIN)

$(CLIENTBIN): includes commonlibs clntlibs $(MISC)/DHCPClient.o $(CLIENT)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CXX) $(CLNT_LDFLAGS) $(OPTS) $(CLNTLINKOPTS) -o $@ $(MISC)/DHCPClient.o $(CLIENT) \
	-L$(MISC)	  -lMisc \
	-L$(ADDRMGR)      -lAddrMgr \
	-L$(CLNTADDRMGR)  -lClntAddrMgr \
	-L$(LOWLEVEL)    \
	-L$(CLNTOPTIONS)  -lClntOptions \
	-L$(OPTIONS)      -lOptions \
	-L$(CLNTTRANSMGR) -lClntTransMgr \
	-L$(CLNTCFGMGR)   -lClntCfgMgr \
	-L$(CFGMGR)       -lCfgMgr \
	-L$(CLNTIFACEMGR) -lClntIfaceMgr \
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(CLNTMESSAGES) -lClntMsg \
	                  -lClntAddrMgr \
	                  -lAddrMgr \
	-L$(MISC)         -lMisc \
	-L$(MESSAGES)     -lMsg \
	-lClntOptions -lOptions -lLowLevel

server: $(SERVERBIN)

$(SERVERBIN): includes commonlibs srvlibs $(MISC)/DHCPServer.o $(SERVER)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CXX) $(SRV_LDFLAGS) $(OPTS) -I $(INCDIR) $(SRVLINKOPTS) -o $@ $(MISC)/DHCPServer.o $(SERVER)  \
	-L$(SRVADDRMGR)   -lSrvAddrMgr \
	-L$(ADDRMGR)      -lAddrMgr \
	-L$(LOWLEVEL)    \
	-L$(SRVOPTIONS)  -lSrvOptions \
	-L$(SRVTRANSMGR) -lSrvTransMgr \
	-L$(SRVCFGMGR)   -lSrvCfgMgr \
	-L$(CFGMGR)      -lCfgMgr \
	-L$(SRVIFACEMGR) -lSrvIfaceMgr \
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(MISC)        -lMisc \
	-lSrvIfaceMgr -lSrvMsg -lSrvCfgMgr \
	-L$(SRVADDRMGR)  -lSrvAddrMgr \
	                 -lAddrMgr \
	-L$(SRVOPTIONS)  -lSrvOptions \
	-L$(SRVTRANSMGR) -lSrvTransMgr \
	-L$(SRVCFGMGR)   -lSrvCfgMgr \
	-L$(SRVIFACEMGR) -lSrvIfaceMgr \
	-L$(SRVMESSAGES) -lSrvMsg \
	-L$(MESSAGES)    -lMsg \
	-L$(MISC)        -lMisc \
	-L$(OPTIONS)     -lOptions \
	-L$(LOWLEVEL)    -lLowLevel

relay: $(RELAYBIN)

$(RELAYBIN): includes commonlibs relaylibs $(MISC)/DHCPRelay.o $(RELAY)
	@echo "[LINK   ] $(SUBDIR)/$@"
	$(CXX) $(REL_LDFLAGS) $(OPTS) -I $(INCDIR) $(SRVLINKOPTS) -o $@ $(MISC)/DHCPRelay.o $(RELAY)  \
	-L$(RELTRANSMGR) -lRelTransMgr \
	-L$(RELCFGMGR)   -lRelCfgMgr \
	-L$(RELIFACEMGR) -lRelIfaceMgr \
	-L$(RELOPTIONS)  -lRelOptions \
	-L$(RELMESSAGES) -lRelMsg \
	-L$(LOWLEVEL)    -lLowLevel \
	-L$(CFGMGR)      -lCfgMgr \
	-L$(IFACEMGR)     -lIfaceMgr \
	-L$(MISC)        -lMisc \
	-L$(MESSAGES)    -lMsg \
	-L$(MISC)        -lMisc \
	-L$(OPTIONS)     -lOptions \
	-lMisc -lIfaceMgr -lLowLevel -lRelTransMgr -lRelCfgMgr -lRelMsg -lRelOptions -lOptions

objs:	includes
	@for dir in $(COMMONSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done
	@for dir in $(CLNTSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done
	@for dir in $(SRVSUBDIRS); do \
		( cd $$dir; $(MAKE) objs ) || exit 1; \
	done


# === libs ===

libs:	commonlibs clntlibs srvlibs

commonlibs:	includes
	@for dir in $(COMMONSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

clntlibs:	includes
	@for dir in $(CLNTSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

srvlibs:	includes
	@for dir in $(SRVSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

relaylibs:	includes
	@for dir in $(RELSUBDIRS); do \
		( cd $$dir; $(MAKE) libs ) || exit 1; \
	done

doc: 
	cd doc; $(MAKE)

oxygen:
	@echo "[DOXYGEN]"
	doxygen oxygen.cfg >oxygen.log 2>oxygen.err

VERSION-linux:
	echo " Operating system " >  VERSION
	echo "------------------" >> VERSION
	uname -o >> VERSION
	echo >> VERSION

	echo " Version " >> VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " C++ compiler used " >> VERSION
	echo "-------------------" >> VERSION
	$(CXX) --version >> VERSION
	echo >> VERSION

	echo " C compiler used " >> VERSION
	echo "-----------------" >> VERSION
	$(CC) --version  >>VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION
#	if [ "$XMLCFLAGS" != "" ]; then
#	    echo "libxml2       : YES" >> VERSION
#	else
#	    echo "libxml2       : NO" >> VERSION
#	fi

VERSION-win:
	echo " Operating system " >  VERSION
	echo "------------------" >> VERSION
	echo " Windows XP/2003"   >> VERSION
	echo >> VERSION

	echo " Version " >> VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " C++ compiler used " >> VERSION
	echo "-------------------" >> VERSION
	echo "MS Visual C++ 2003 edition" >> VERSION
	echo >> VERSION

	echo " C compiler used " >> VERSION
	echo "-----------------" >> VERSION
	echo "MS Visual C++ 2003 edition" >> VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION

VERSION-src:
	echo " Version " > VERSION
	echo "---------" >> VERSION
	echo "$(VERSION)" >> VERSION
	echo >> VERSION

	echo " Date " >> VERSION
	echo "------" >> VERSION
	date +%Y-%m-%d >> VERSION
	echo >> VERSION

release:
	echo "Following release targets are available:"
	echo "release-linux - Linux binaries"
	echo "release-win32 - Windows binaries"
	echo "release-src   - Sources"
	echo "release-doc   - Documentation"
	echo "release-deb   - DEB package"
	echo "release-rpm   - RPM package"
	echo "release-all   - all of the above"
	echo
	echo "To make release-win32 work, place dibbler-server.exe and"
	echo "dibbler-client.exe in this directory."

release-linux: VERSION-linux
	@echo "[STRIP  ] $(SERVERBIN)"
	strip $(SERVERBIN)
	@echo "[STRIP  ] $(CLIENTBIN)"
	strip $(CLIENTBIN)
	@echo "[STRIP  ] $(RELAYBIN)"
	strip $(RELAYBIN)
	@echo "[TAR/GZ ] dibbler-$(VERSION)-linux.tar.gz"
	tar czvf dibbler-$(VERSION)-linux.tar.gz                                   \
		 $(SERVERBIN) $(CLIENTBIN) $(RELAYBIN) *.conf   \
		 doc/man/* CHANGELOG RELNOTES LICENSE VERSION doc/dibbler-user.pdf > filelist-linux

release-win32: VERSION-win doc
	@echo "[TAR/GZ ] dibbler-$(VERSION)-win32.tar.gz"
	tar czvf dibbler-$(VERSION)-win32.tar.gz                   \
		 dibbler-server.exe dibbler-client.exe dibbler-relay.exe \
                 *.conf                         \
		 CHANGELOG RELNOTES LICENSE VERSION doc/dibbler-user.pdf > filelist-win32

release-src: VERSION-src 
	@echo "[RM     ] dibbler-$(VERSION)-src.tar.gz"
	rm -f dibbler-$(VERSION)-src.tar.gz
	$(MAKE) clean
	if [ -e bison++/Makefile ]; then echo "[CLEAN  ] /bison++"; $(MAKE) -C bison++ clean; fi
	echo "$(VERSION)" > ../dibbler-version
	cd ..; echo dibbler-`cat dibbler-version`.tar.gz
	@echo "[TAR/GZ ] ../dibbler-$(VERSION).tar.gz"
	mv ../dibbler ../dibbler-$(VERSION)
	cd ..; tar czvf dibbler-tmp.tar.gz --exclude CVS --exclude '*.exe' --exclude '*.o' \
        --exclude '*.a' --exclude '*.deb' --exclude '*.tar.gz' dibbler-`cat dibbler-version`
	mv ../dibbler-`cat ../dibbler-version` ../dibbler
	@echo "[RENAME ] dibbler-$(VERSION)-src.tar.gz"
	mv ../dibbler-tmp.tar.gz dibbler-$(VERSION)-src.tar.gz
	rm ../dibbler-version

orig:
	@echo "[RM     ] debian/"
	rm -rf debian/
	@echo "[RM     ] */CVS"
	find . -type d -name CVS -exec rm -rf {} \;
	for i in doc/rfc doc/rfc-drafts Port-win32 Port-winnt2k ; do                                      \
	echo  "[RM     ] $$i" ;                                                                           \
	rm -f tmp;                                                                                        \
	ls -l $$i > tmp ;                                                                                 \
	rm -f $$i/* ;                                                                                     \
	echo "Following Win32-related files were removed from the Debian orig package" >  $$i/INFO-DSFG ; \
	echo "due to possible violation of the Debian Free Software Guidelines:" >> $$i/INFO-DSFG ;       \
	echo "" >> $$i/INFO-DSFG ;                                                                        \
	cat tmp >> $$i/INFO-DSFG ;                                                                        \
	rm -f tmp;                                                                                        \
	done

deb:
	if [ ! -e ../dibbler_$(VERSION).orig.tar.gz ]; then                 \
	echo " Make sure that there is a file ../dibbler_$(VERSION).orig.tar.gz"; false; fi
	if [ -d ../dibbler ]; then \
	echo "[RENAME ] ../dibbler-$(VERSION)" ; mv ../dibbler ../dibbler-$(VERSION); fi
	dpkg-buildpackage -rfakeroot

release-doc: VERSION-src doc oxygen
	@echo "[TAR/GZ ] dibbler-$(VERSION)-doc.tar.gz"
	tar czvf dibbler-$(VERSION)-doc.tar.gz VERSION RELNOTES LICENSE CHANGELOG \
                 doc/*.pdf doc/html doc/rfc doc/rfc-drafts > filelist-doc

release-gentoo: VERSION-linux
	@echo "[TAR/GZ ] dibbler-tmp.tar.gz"
	cd $(PORTDIR)/gentoo; tar czvf ../../dibbler-tmp.tar.gz --exclude CVS net-misc
	@echo "[RENAME ] dibbler-$(VERSION)-gentoo.tar.gz"
	mv dibbler-tmp.tar.gz dibbler-$(VERSION)-gentoo.tar.gz

release-all: release-src release-linux release-doc release-deb release-rpm release-win32

release-deb: VERSION-linux clean
	cd debian
	dpkg-buildpackage -rfakeroot

release-rpm: VERSION-linux release-src
	$(MKDIR) $(PORTDIR)/redhat/BUILD
	$(MKDIR) $(PORTDIR)/redhat/RPMS/athlon
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i386
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i486
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i586
	$(MKDIR) $(PORTDIR)/redhat/RPMS/i686
	$(MKDIR) $(PORTDIR)/redhat/RPMS/noarch
	$(MKDIR) $(PORTDIR)/redhat/SOURCES
	$(MKDIR) $(PORTDIR)/redhat/SPECS
	$(MKDIR) $(PORTDIR)/redhat/SRPMS
	@echo "[CP     ] $(PORTDIR)/redhat/SOURCES/dibbler-$(VERSION)-src.tar.gz"
	$(CP) dibbler-$(VERSION)-src.tar.gz $(PORTDIR)/redhat/SOURCES
	@echo "[RPM    ] $(PORTDIR)/redhat/SPEC/dibbler-$(VERSION).spec"
	rpmbuild --define "_topdir `pwd`/$(PORTDIR)/redhat" -bb $(PORTDIR)/redhat/SPECS/dibbler-$(VERSION).spec
	cd $(PORTDIR)/redhat/RPMS/i386; for file in *; do \
	echo "[CP     ] $$file"; \
	$(CP) $$file ../../../.. ; \
	done

install: 
	$(MKDIR) $(INST_WORKDIR)
	$(MKDIR) $(INST_BINDIR)
	$(MKDIR) $(INST_CONFDIR)
	$(MKDIR) $(INST_MANDIR)
	@echo "[INSTALL] $(SERVERBIN)"
	$(INSTALL) -m 755 $(SERVERBIN) $(INST_BINDIR)/
	@echo "[INSTALL] $(CLIENTBIN)"
	$(INSTALL) -m 755 $(CLIENTBIN) $(INST_BINDIR)/
	@echo "[INSTALL] $(RELAYBIN)"
	$(INSTALL) -m 755 $(RELAYBIN) $(INST_BINDIR)/
	@for dir in *.conf; do \
		(echo "[INSTALL] $$dir" && $(INSTALL) -m 644 $$dir $(INST_CONFDIR)) \
	done
	$(MKDIR) $(INST_MANDIR)/man8
	@for dir in doc/man/*.8; do \
		(echo "[INSTALL] $$dir" && $(INSTALL) -m 644 $$dir $(INST_MANDIR)/man8) \
	done
	$(MKDIR) $(INST_DOCDIR)/dibbler
	@echo "[INSTALL] /doc/dibbler-user.pdf"
	$(INSTALL) -m 644 doc/dibbler-user.pdf $(INST_DOCDIR)/dibbler/dibbler-user.pdf
	@echo "[INSTALL] /doc/dibbler-devel.pdf"
	$(INSTALL) -m 644 doc/dibbler-devel.pdf $(INST_DOCDIR)/dibbler/dibbler-devel.pdf
	@echo "[INSTALL] CHANGELOG"
	$(INSTALL) -m 644 CHANGELOG $(INST_DOCDIR)/dibbler/changelog
	gzip -9 $(INST_DOCDIR)/dibbler/changelog

snapshot: clean
	cvs update -d
	rm -f dibbler-`date +%Y%m%d`-CVS.tar.gz
	cd ..; tar czf dibbler-CVS.tar.gz dibbler
	mv ../dibbler-CVS.tar.gz dibbler-`date +%Y%m%d`-CVS.tar.gz
	echo "Snapshot has been stored in the dibbler-`date +%Y%m%d`-CVS.tar.gz file."

help:
	@echo "Welcome to Dibbler building help system"
	@echo "To build specific target, type: make target"
	@echo "There are several targets which can be useful:"
	@echo
	@echo "server         - builds DHCPv6 server"
	@echo "client         - builds DHCPv6 client"
	@echo "relay          - builds DHCPv6 relay"
	@echo "install        - install server, client and relay in /usr/local"
	@echo
	@echo "bison          - builds bison++ (required if you want to generate parsers by yourself)"
	@echo "parser         - generate parser files"
	@echo "doc            - generate User's Guide and Developer's Guide PDF files (LaTeX system is required)"
	@echo "oxygen         - generate Source Documentation (Doxygen is required)"
	@echo "snapshot       - generate CVS snapshot"
	@echo "clean          - cleans source tree"
	@echo
	@echo "release-linux  - prepares tar.gz with Linux binaries"
	@echo "release-win32  - prepares tar.gz with Windows binaries"
	@echo "release-src    - prepares tar.gz with sources"
	@echo "release-doc    - prepares tar.gz with User/Developer documentation (LaTeX is required)"
	@echo "release-oxygen - prepares tar.gz with detailed Developer documentation (doxygen is required)"
	@echo "release-rpm    - prepares RPM archive (for RedHat, PLD, Mandrake or Fedora Core) with binaries"
	@echo "release-deb    - prepares DEB archive (for Debian systems) with binaries"
	@echo "release-gentoo - prepares ebuild (for Gentoo systems) with building instructions"
	@echo 

fixme:
	rm -rf FIXME
	find . -name \*.cpp -exec grep -H "FIXME" {} \; | tee FIXME

tags:
	@echo "[TAGS   ]"
	rm -f TAGS
	find . -name '*.cpp' -or -name '*.h' | xargs etags

clean-libs:
	find . -name *.a -exec rm {} \;

links: includes
clobber: clean

.PHONY: release-winxp release-src release-linux release-deb relase-rpm release-all VERSION VERSION-win doc parser snapshot help
