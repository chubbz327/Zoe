# This Makefile is for the Zoe extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.78 (Revision: 67800) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     AUTHOR => [q[dinni bartholomew <dinnibartholomew@gmail.com>]]
#     BUILD_REQUIRES => {  }
#     CONFIGURE_REQUIRES => {  }
#     EXE_FILES => [q[script/zoe], q[script/zoe-generator]]
#     LICENSE => q[artistic_2]
#     MIN_PERL_VERSION => q[5.010001]
#     PREREQ_PM => { DateTime=>q[0], String::CamelCase=>q[0.02], DBD::SQLite=>q[1.37], File::Touch=>q[0.08], Data::GUID=>q[0.046], Lingua::EN::Inflect=>q[1.895], JSON::Parse=>q[0], DateTime::Format::DBI=>q[0], DBI=>q[1.623], File::Slurp=>q[9999.19], SQL::Abstract=>q[1.73], SQL::Translator=>q[0.11016], YAML::Tiny=>q[1.51], Log::Message::Simple=>q[0.08], Mojolicious=>q[4.22], Path::Class=>q[0.32], SQL::Abstract::More=>q[1.15], File::Copy::Recursive=>q[0.38] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.50]
#     test => { TESTS=>q[t/*.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl5/5.14/i686-cygwin-threads-64int/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = gcc-4
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = dll
DLSRC = dl_dlopen.xs
EXE_EXT = .exe
FULL_AR = /usr/bin/ar
LD = g++-4
LDDLFLAGS =  --shared  -Wl,--enable-auto-import -Wl,--export-all-symbols -Wl,--enable-auto-image-base -L/usr/local/lib -fstack-protector
LDFLAGS =  -Wl,--enable-auto-import -Wl,--export-all-symbols -Wl,--enable-auto-image-base -fstack-protector -L/usr/local/lib
LIBC = /usr/lib/libc.a
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = cygwin
OSVERS = 1.7.15\(0.26053\)
RANLIB = :
SITELIBEXP = /usr/lib/perl5/site_perl/5.14
SITEARCHEXP = /usr/lib/perl5/site_perl/5.14/i686-cygwin-threads-64int
SO = dll
VENDORARCHEXP = /usr/lib/perl5/vendor_perl/5.14/i686-cygwin-threads-64int
VENDORLIBEXP = /usr/lib/perl5/vendor_perl/5.14


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = Zoe
NAME_SYM = Zoe
VERSION = 0.50
VERSION_MACRO = VERSION
VERSION_SYM = 0_50
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.50
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /usr
SITEPREFIX = /usr
VENDORPREFIX = /usr
INSTALLPRIVLIB = /usr/lib/perl5/5.14
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /usr/lib/perl5/site_perl/5.14
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /usr/lib/perl5/vendor_perl/5.14
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /usr/lib/perl5/5.14/i686-cygwin-threads-64int
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /usr/lib/perl5/site_perl/5.14/i686-cygwin-threads-64int
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /usr/lib/perl5/vendor_perl/5.14/i686-cygwin-threads-64int
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /usr/local/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = /usr/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = /usr/local/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = /usr/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = /usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /usr/share/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = /usr/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /usr/share/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = /usr/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /usr/lib/perl5/5.14
PERL_ARCHLIB = /usr/lib/perl5/5.14/i686-cygwin-threads-64int
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl5/5.14/i686-cygwin-threads-64int/CORE
PERL = /usr/bin/perl.exe
FULLPERL = /usr/bin/perl.exe
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/lib/perl5/site_perl/5.14/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.78
MM_REVISION = 67800

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = Zoe
BASEEXT = Zoe
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/Zoe.pm \
	lib/Zoe/DataObject.pm \
	lib/Zoe/Helpers.pm \
	lib/Zoe/ObjectMeta.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = $(PERL_INC)/cygperl5_14.dll
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Zoe.pm \
	lib/Zoe/AuthenticationController.pm \
	lib/Zoe/AuthorizationManager.pm \
	lib/Zoe/DO/Cart.pm \
	lib/Zoe/DO/CartItem.pm \
	lib/Zoe/DataObject.pm \
	lib/Zoe/DataObjectAuthenticationManager.pm \
	lib/Zoe/Example.pm \
	lib/Zoe/Helpers.pm \
	lib/Zoe/LDAPAuthenticationManager.pm \
	lib/Zoe/ObjectMeta.pm \
	lib/Zoe/PayPayTransactionController.pm \
	lib/Zoe/PayPayTransactionController.pm_old \
	lib/Zoe/ZoeController.pm \
	lib/Zoe/Zoe_files/config/db.yml \
	lib/Zoe/Zoe_files/public/assets/css/bootstrap-responsive.css \
	lib/Zoe/Zoe_files/public/assets/css/bootstrap.css \
	lib/Zoe/Zoe_files/public/assets/css/docs.css \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-114-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-144-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-57-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-72-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/favicon.ico \
	lib/Zoe/Zoe_files/public/assets/ico/favicon.png \
	lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings-white.png \
	lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings.png \
	lib/Zoe/Zoe_files/public/assets/js/README.md \
	lib/Zoe/Zoe_files/public/assets/js/application.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-affix.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-alert.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-button.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-carousel.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-collapse.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-dropdown.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-modal.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-popover.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-scrollspy.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-tab.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-tooltip.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-transition.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-typeahead.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap.min.js \
	lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.css \
	lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.js \
	lib/Zoe/Zoe_files/public/assets/js/holder/holder.js \
	lib/Zoe/Zoe_files/public/assets/js/html5shiv.js \
	lib/Zoe/Zoe_files/public/assets/js/jquery.js \
	lib/Zoe/Zoe_files/public/assets/js/jquery.min.map \
	lib/Zoe/Zoe_files/public/assets/js/jquery.validate.js \
	lib/Zoe/Zoe_files/public/index.html \
	lib/Zoe/Zoe_files/t/00-data-scaffold.t \
	lib/Zoe/Zoe_files/t/DataObject.t \
	lib/Zoe/Zoe_files/t/DataObject.t_single_relationship_to_object \
	lib/Zoe/Zoe_files/t/basic.t \
	lib/Zoe/Zoe_files/t/t.pl \
	lib/Zoe/Zoe_files/templates/cart.html.ep \
	lib/Zoe/Zoe_files/templates/default.html.ep \
	lib/Zoe/Zoe_files/templates/example/welcome.html.ep \
	lib/Zoe/Zoe_files/templates/layouts/default.html.ep \
	lib/Zoe/Zoe_files/templates/model.tpl.pm \
	lib/Zoe/Zoe_files/templates/not_authorized.html.ep \
	lib/Zoe/Zoe_files/templates/not_authorized_html.ep \
	lib/Zoe/Zoe_files/templates/object_controller.tpl.pm \
	lib/Zoe/Zoe_files/templates/paypal_transaction.html.ep \
	lib/Zoe/Zoe_files/templates/paypal_transaction_failed.html.ep \
	lib/Zoe/Zoe_files/templates/routes.tpl \
	lib/Zoe/Zoe_files/templates/routes.tpl.yml \
	lib/Zoe/Zoe_files/templates/routes.tpl_old \
	lib/Zoe/Zoe_files/templates/show_all_view.tpl \
	lib/Zoe/Zoe_files/templates/show_auth_object_create_view.tpl \
	lib/Zoe/Zoe_files/templates/show_auth_object_edit_view.tpl \
	lib/Zoe/Zoe_files/templates/show_create_view.tpl \
	lib/Zoe/Zoe_files/templates/show_edit_view.tpl \
	lib/Zoe/Zoe_files/templates/show_view.tpl \
	lib/Zoe/Zoe_files/templates/signin.html.ep \
	lib/Zoe/Zoe_files/templates/startup_controller.tpl.pm \
	lib/Zoe/Zoe_files/templates/view_cart.html.ep \
	lib/Zoe/Zoe_files/yml/mysql_example.yml \
	lib/Zoe/Zoe_files/yml/postgres_example.yml \
	lib/Zoe/Zoe_files/yml/sqlite_example.yml \
	lib/Zoe/Zoe_files/yml/tutorial_example.yml \
	lib/Zoe/public/assets/css/bootstrap-responsive.css \
	lib/Zoe/public/assets/css/bootstrap.css \
	lib/Zoe/public/assets/css/bootstrap.min.css \
	lib/Zoe/public/assets/css/docs.css \
	lib/Zoe/public/assets/ico/apple-touch-icon-114-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-144-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-57-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-72-precomposed.png \
	lib/Zoe/public/assets/ico/favicon.ico \
	lib/Zoe/public/assets/ico/favicon.png \
	lib/Zoe/public/assets/img/glyphicons-halflings-white.png \
	lib/Zoe/public/assets/img/glyphicons-halflings.png \
	lib/Zoe/public/assets/js/README.md \
	lib/Zoe/public/assets/js/application.js \
	lib/Zoe/public/assets/js/bootstrap-affix.js \
	lib/Zoe/public/assets/js/bootstrap-alert.js \
	lib/Zoe/public/assets/js/bootstrap-button.js \
	lib/Zoe/public/assets/js/bootstrap-carousel.js \
	lib/Zoe/public/assets/js/bootstrap-collapse.js \
	lib/Zoe/public/assets/js/bootstrap-dropdown.js \
	lib/Zoe/public/assets/js/bootstrap-modal.js \
	lib/Zoe/public/assets/js/bootstrap-popover.js \
	lib/Zoe/public/assets/js/bootstrap-scrollspy.js \
	lib/Zoe/public/assets/js/bootstrap-tab.js \
	lib/Zoe/public/assets/js/bootstrap-tooltip.js \
	lib/Zoe/public/assets/js/bootstrap-transition.js \
	lib/Zoe/public/assets/js/bootstrap-typeahead.js \
	lib/Zoe/public/assets/js/bootstrap.js \
	lib/Zoe/public/assets/js/bootstrap.min.js \
	lib/Zoe/public/assets/js/google-code-prettify/prettify.css \
	lib/Zoe/public/assets/js/google-code-prettify/prettify.js \
	lib/Zoe/public/assets/js/holder/holder.js \
	lib/Zoe/public/assets/js/html5shiv.js \
	lib/Zoe/public/assets/js/jquery.js \
	lib/Zoe/public/assets/js/jquery.validate.js \
	lib/Zoe/public/index.html \
	lib/Zoe/templates/example/welcome.html.ep \
	lib/Zoe/templates/layouts/default.html.ep \
	lib/Zoe/templates/tutorial.html.ep \
	lib/Zoe/templates/upload.html.ep

PM_TO_BLIB = lib/Zoe.pm \
	blib/lib/Zoe.pm \
	lib/Zoe/AuthenticationController.pm \
	blib/lib/Zoe/AuthenticationController.pm \
	lib/Zoe/AuthorizationManager.pm \
	blib/lib/Zoe/AuthorizationManager.pm \
	lib/Zoe/DO/Cart.pm \
	blib/lib/Zoe/DO/Cart.pm \
	lib/Zoe/DO/CartItem.pm \
	blib/lib/Zoe/DO/CartItem.pm \
	lib/Zoe/DataObject.pm \
	blib/lib/Zoe/DataObject.pm \
	lib/Zoe/DataObjectAuthenticationManager.pm \
	blib/lib/Zoe/DataObjectAuthenticationManager.pm \
	lib/Zoe/Example.pm \
	blib/lib/Zoe/Example.pm \
	lib/Zoe/Helpers.pm \
	blib/lib/Zoe/Helpers.pm \
	lib/Zoe/LDAPAuthenticationManager.pm \
	blib/lib/Zoe/LDAPAuthenticationManager.pm \
	lib/Zoe/ObjectMeta.pm \
	blib/lib/Zoe/ObjectMeta.pm \
	lib/Zoe/PayPayTransactionController.pm \
	blib/lib/Zoe/PayPayTransactionController.pm \
	lib/Zoe/PayPayTransactionController.pm_old \
	blib/lib/Zoe/PayPayTransactionController.pm_old \
	lib/Zoe/ZoeController.pm \
	blib/lib/Zoe/ZoeController.pm \
	lib/Zoe/Zoe_files/config/db.yml \
	blib/lib/Zoe/Zoe_files/config/db.yml \
	lib/Zoe/Zoe_files/public/assets/css/bootstrap-responsive.css \
	blib/lib/Zoe/Zoe_files/public/assets/css/bootstrap-responsive.css \
	lib/Zoe/Zoe_files/public/assets/css/bootstrap.css \
	blib/lib/Zoe/Zoe_files/public/assets/css/bootstrap.css \
	lib/Zoe/Zoe_files/public/assets/css/docs.css \
	blib/lib/Zoe/Zoe_files/public/assets/css/docs.css \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-114-precomposed.png \
	blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-114-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-144-precomposed.png \
	blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-144-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-57-precomposed.png \
	blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-57-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-72-precomposed.png \
	blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-72-precomposed.png \
	lib/Zoe/Zoe_files/public/assets/ico/favicon.ico \
	blib/lib/Zoe/Zoe_files/public/assets/ico/favicon.ico \
	lib/Zoe/Zoe_files/public/assets/ico/favicon.png \
	blib/lib/Zoe/Zoe_files/public/assets/ico/favicon.png \
	lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings-white.png \
	blib/lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings-white.png \
	lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings.png \
	blib/lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings.png \
	lib/Zoe/Zoe_files/public/assets/js/README.md \
	blib/lib/Zoe/Zoe_files/public/assets/js/README.md \
	lib/Zoe/Zoe_files/public/assets/js/application.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/application.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-affix.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-affix.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-alert.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-alert.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-button.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-button.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-carousel.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-carousel.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-collapse.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-collapse.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-dropdown.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-dropdown.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-modal.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-modal.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-popover.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-popover.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-scrollspy.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-scrollspy.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-tab.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-tab.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-tooltip.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-tooltip.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-transition.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-transition.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap-typeahead.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-typeahead.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap.js \
	lib/Zoe/Zoe_files/public/assets/js/bootstrap.min.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap.min.js \
	lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.css \
	blib/lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.css \
	lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.js \
	lib/Zoe/Zoe_files/public/assets/js/holder/holder.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/holder/holder.js \
	lib/Zoe/Zoe_files/public/assets/js/html5shiv.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/html5shiv.js \
	lib/Zoe/Zoe_files/public/assets/js/jquery.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/jquery.js \
	lib/Zoe/Zoe_files/public/assets/js/jquery.min.map \
	blib/lib/Zoe/Zoe_files/public/assets/js/jquery.min.map \
	lib/Zoe/Zoe_files/public/assets/js/jquery.validate.js \
	blib/lib/Zoe/Zoe_files/public/assets/js/jquery.validate.js \
	lib/Zoe/Zoe_files/public/index.html \
	blib/lib/Zoe/Zoe_files/public/index.html \
	lib/Zoe/Zoe_files/t/00-data-scaffold.t \
	blib/lib/Zoe/Zoe_files/t/00-data-scaffold.t \
	lib/Zoe/Zoe_files/t/DataObject.t \
	blib/lib/Zoe/Zoe_files/t/DataObject.t \
	lib/Zoe/Zoe_files/t/DataObject.t_single_relationship_to_object \
	blib/lib/Zoe/Zoe_files/t/DataObject.t_single_relationship_to_object \
	lib/Zoe/Zoe_files/t/basic.t \
	blib/lib/Zoe/Zoe_files/t/basic.t \
	lib/Zoe/Zoe_files/t/t.pl \
	blib/lib/Zoe/Zoe_files/t/t.pl \
	lib/Zoe/Zoe_files/templates/cart.html.ep \
	blib/lib/Zoe/Zoe_files/templates/cart.html.ep \
	lib/Zoe/Zoe_files/templates/default.html.ep \
	blib/lib/Zoe/Zoe_files/templates/default.html.ep \
	lib/Zoe/Zoe_files/templates/example/welcome.html.ep \
	blib/lib/Zoe/Zoe_files/templates/example/welcome.html.ep \
	lib/Zoe/Zoe_files/templates/layouts/default.html.ep \
	blib/lib/Zoe/Zoe_files/templates/layouts/default.html.ep \
	lib/Zoe/Zoe_files/templates/model.tpl.pm \
	blib/lib/Zoe/Zoe_files/templates/model.tpl.pm \
	lib/Zoe/Zoe_files/templates/not_authorized.html.ep \
	blib/lib/Zoe/Zoe_files/templates/not_authorized.html.ep \
	lib/Zoe/Zoe_files/templates/not_authorized_html.ep \
	blib/lib/Zoe/Zoe_files/templates/not_authorized_html.ep \
	lib/Zoe/Zoe_files/templates/object_controller.tpl.pm \
	blib/lib/Zoe/Zoe_files/templates/object_controller.tpl.pm \
	lib/Zoe/Zoe_files/templates/paypal_transaction.html.ep \
	blib/lib/Zoe/Zoe_files/templates/paypal_transaction.html.ep \
	lib/Zoe/Zoe_files/templates/paypal_transaction_failed.html.ep \
	blib/lib/Zoe/Zoe_files/templates/paypal_transaction_failed.html.ep \
	lib/Zoe/Zoe_files/templates/routes.tpl \
	blib/lib/Zoe/Zoe_files/templates/routes.tpl \
	lib/Zoe/Zoe_files/templates/routes.tpl.yml \
	blib/lib/Zoe/Zoe_files/templates/routes.tpl.yml \
	lib/Zoe/Zoe_files/templates/routes.tpl_old \
	blib/lib/Zoe/Zoe_files/templates/routes.tpl_old \
	lib/Zoe/Zoe_files/templates/show_all_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_all_view.tpl \
	lib/Zoe/Zoe_files/templates/show_auth_object_create_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_auth_object_create_view.tpl \
	lib/Zoe/Zoe_files/templates/show_auth_object_edit_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_auth_object_edit_view.tpl \
	lib/Zoe/Zoe_files/templates/show_create_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_create_view.tpl \
	lib/Zoe/Zoe_files/templates/show_edit_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_edit_view.tpl \
	lib/Zoe/Zoe_files/templates/show_view.tpl \
	blib/lib/Zoe/Zoe_files/templates/show_view.tpl \
	lib/Zoe/Zoe_files/templates/signin.html.ep \
	blib/lib/Zoe/Zoe_files/templates/signin.html.ep \
	lib/Zoe/Zoe_files/templates/startup_controller.tpl.pm \
	blib/lib/Zoe/Zoe_files/templates/startup_controller.tpl.pm \
	lib/Zoe/Zoe_files/templates/view_cart.html.ep \
	blib/lib/Zoe/Zoe_files/templates/view_cart.html.ep \
	lib/Zoe/Zoe_files/yml/mysql_example.yml \
	blib/lib/Zoe/Zoe_files/yml/mysql_example.yml \
	lib/Zoe/Zoe_files/yml/postgres_example.yml \
	blib/lib/Zoe/Zoe_files/yml/postgres_example.yml \
	lib/Zoe/Zoe_files/yml/sqlite_example.yml \
	blib/lib/Zoe/Zoe_files/yml/sqlite_example.yml \
	lib/Zoe/Zoe_files/yml/tutorial_example.yml \
	blib/lib/Zoe/Zoe_files/yml/tutorial_example.yml \
	lib/Zoe/public/assets/css/bootstrap-responsive.css \
	blib/lib/Zoe/public/assets/css/bootstrap-responsive.css \
	lib/Zoe/public/assets/css/bootstrap.css \
	blib/lib/Zoe/public/assets/css/bootstrap.css \
	lib/Zoe/public/assets/css/bootstrap.min.css \
	blib/lib/Zoe/public/assets/css/bootstrap.min.css \
	lib/Zoe/public/assets/css/docs.css \
	blib/lib/Zoe/public/assets/css/docs.css \
	lib/Zoe/public/assets/ico/apple-touch-icon-114-precomposed.png \
	blib/lib/Zoe/public/assets/ico/apple-touch-icon-114-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-144-precomposed.png \
	blib/lib/Zoe/public/assets/ico/apple-touch-icon-144-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-57-precomposed.png \
	blib/lib/Zoe/public/assets/ico/apple-touch-icon-57-precomposed.png \
	lib/Zoe/public/assets/ico/apple-touch-icon-72-precomposed.png \
	blib/lib/Zoe/public/assets/ico/apple-touch-icon-72-precomposed.png \
	lib/Zoe/public/assets/ico/favicon.ico \
	blib/lib/Zoe/public/assets/ico/favicon.ico \
	lib/Zoe/public/assets/ico/favicon.png \
	blib/lib/Zoe/public/assets/ico/favicon.png \
	lib/Zoe/public/assets/img/glyphicons-halflings-white.png \
	blib/lib/Zoe/public/assets/img/glyphicons-halflings-white.png \
	lib/Zoe/public/assets/img/glyphicons-halflings.png \
	blib/lib/Zoe/public/assets/img/glyphicons-halflings.png \
	lib/Zoe/public/assets/js/README.md \
	blib/lib/Zoe/public/assets/js/README.md \
	lib/Zoe/public/assets/js/application.js \
	blib/lib/Zoe/public/assets/js/application.js \
	lib/Zoe/public/assets/js/bootstrap-affix.js \
	blib/lib/Zoe/public/assets/js/bootstrap-affix.js \
	lib/Zoe/public/assets/js/bootstrap-alert.js \
	blib/lib/Zoe/public/assets/js/bootstrap-alert.js \
	lib/Zoe/public/assets/js/bootstrap-button.js \
	blib/lib/Zoe/public/assets/js/bootstrap-button.js \
	lib/Zoe/public/assets/js/bootstrap-carousel.js \
	blib/lib/Zoe/public/assets/js/bootstrap-carousel.js \
	lib/Zoe/public/assets/js/bootstrap-collapse.js \
	blib/lib/Zoe/public/assets/js/bootstrap-collapse.js \
	lib/Zoe/public/assets/js/bootstrap-dropdown.js \
	blib/lib/Zoe/public/assets/js/bootstrap-dropdown.js \
	lib/Zoe/public/assets/js/bootstrap-modal.js \
	blib/lib/Zoe/public/assets/js/bootstrap-modal.js \
	lib/Zoe/public/assets/js/bootstrap-popover.js \
	blib/lib/Zoe/public/assets/js/bootstrap-popover.js \
	lib/Zoe/public/assets/js/bootstrap-scrollspy.js \
	blib/lib/Zoe/public/assets/js/bootstrap-scrollspy.js \
	lib/Zoe/public/assets/js/bootstrap-tab.js \
	blib/lib/Zoe/public/assets/js/bootstrap-tab.js \
	lib/Zoe/public/assets/js/bootstrap-tooltip.js \
	blib/lib/Zoe/public/assets/js/bootstrap-tooltip.js \
	lib/Zoe/public/assets/js/bootstrap-transition.js \
	blib/lib/Zoe/public/assets/js/bootstrap-transition.js \
	lib/Zoe/public/assets/js/bootstrap-typeahead.js \
	blib/lib/Zoe/public/assets/js/bootstrap-typeahead.js \
	lib/Zoe/public/assets/js/bootstrap.js \
	blib/lib/Zoe/public/assets/js/bootstrap.js \
	lib/Zoe/public/assets/js/bootstrap.min.js \
	blib/lib/Zoe/public/assets/js/bootstrap.min.js \
	lib/Zoe/public/assets/js/google-code-prettify/prettify.css \
	blib/lib/Zoe/public/assets/js/google-code-prettify/prettify.css \
	lib/Zoe/public/assets/js/google-code-prettify/prettify.js \
	blib/lib/Zoe/public/assets/js/google-code-prettify/prettify.js \
	lib/Zoe/public/assets/js/holder/holder.js \
	blib/lib/Zoe/public/assets/js/holder/holder.js \
	lib/Zoe/public/assets/js/html5shiv.js \
	blib/lib/Zoe/public/assets/js/html5shiv.js \
	lib/Zoe/public/assets/js/jquery.js \
	blib/lib/Zoe/public/assets/js/jquery.js \
	lib/Zoe/public/assets/js/jquery.validate.js \
	blib/lib/Zoe/public/assets/js/jquery.validate.js \
	lib/Zoe/public/index.html \
	blib/lib/Zoe/public/index.html \
	lib/Zoe/templates/example/welcome.html.ep \
	blib/lib/Zoe/templates/example/welcome.html.ep \
	lib/Zoe/templates/layouts/default.html.ep \
	blib/lib/Zoe/templates/layouts/default.html.ep \
	lib/Zoe/templates/tutorial.html.ep \
	blib/lib/Zoe/templates/tutorial.html.ep \
	lib/Zoe/templates/upload.html.ep \
	blib/lib/Zoe/templates/upload.html.ep


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.78
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = Zoe
DISTVNAME = Zoe-0.50


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/Zoe.pm \
	lib/Zoe/DataObject.pm \
	lib/Zoe/Helpers.pm \
	lib/Zoe/ObjectMeta.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/Zoe.pm $(INST_MAN3DIR)/Zoe.$(MAN3EXT) \
	  lib/Zoe/DataObject.pm $(INST_MAN3DIR)/Zoe.DataObject.$(MAN3EXT) \
	  lib/Zoe/Helpers.pm $(INST_MAN3DIR)/Zoe.Helpers.$(MAN3EXT) \
	  lib/Zoe/ObjectMeta.pm $(INST_MAN3DIR)/Zoe.ObjectMeta.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/zoe script/zoe-generator

pure_all :: $(INST_SCRIPT)/zoe $(INST_SCRIPT)/zoe-generator
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/zoe $(INST_SCRIPT)/zoe-generator 

$(INST_SCRIPT)/zoe : script/zoe $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/zoe
	$(CP) script/zoe $(INST_SCRIPT)/zoe
	$(FIXIN) $(INST_SCRIPT)/zoe
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/zoe

$(INST_SCRIPT)/zoe-generator : script/zoe-generator $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/zoe-generator
	$(CP) script/zoe-generator $(INST_SCRIPT)/zoe-generator
	$(FIXIN) $(INST_SCRIPT)/zoe-generator
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/zoe-generator



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile : create_distdir
	$(NOECHO) $(ECHO) Generating META.yml
	$(NOECHO) $(ECHO) '---' > META_new.yml
	$(NOECHO) $(ECHO) 'abstract: unknown' >> META_new.yml
	$(NOECHO) $(ECHO) 'author:' >> META_new.yml
	$(NOECHO) $(ECHO) '  - '\''dinni bartholomew <dinnibartholomew@gmail.com>'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'build_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: 0' >> META_new.yml
	$(NOECHO) $(ECHO) 'configure_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: 0' >> META_new.yml
	$(NOECHO) $(ECHO) 'dynamic_config: 1' >> META_new.yml
	$(NOECHO) $(ECHO) 'generated_by: '\''ExtUtils::MakeMaker version 6.78, CPAN::Meta::Converter version 2.132830'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'license: artistic_2' >> META_new.yml
	$(NOECHO) $(ECHO) 'meta-spec:' >> META_new.yml
	$(NOECHO) $(ECHO) '  url: http://module-build.sourceforge.net/META-spec-v1.4.html' >> META_new.yml
	$(NOECHO) $(ECHO) '  version: 1.4' >> META_new.yml
	$(NOECHO) $(ECHO) 'name: Zoe' >> META_new.yml
	$(NOECHO) $(ECHO) 'no_index:' >> META_new.yml
	$(NOECHO) $(ECHO) '  directory:' >> META_new.yml
	$(NOECHO) $(ECHO) '    - t' >> META_new.yml
	$(NOECHO) $(ECHO) '    - inc' >> META_new.yml
	$(NOECHO) $(ECHO) 'requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBD::SQLite: 1.37' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBI: 1.623' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::GUID: 0.046' >> META_new.yml
	$(NOECHO) $(ECHO) '  DateTime: 0' >> META_new.yml
	$(NOECHO) $(ECHO) '  DateTime::Format::DBI: 0' >> META_new.yml
	$(NOECHO) $(ECHO) '  File::Copy::Recursive: 0.38' >> META_new.yml
	$(NOECHO) $(ECHO) '  File::Slurp: 9999.19' >> META_new.yml
	$(NOECHO) $(ECHO) '  File::Touch: 0.08' >> META_new.yml
	$(NOECHO) $(ECHO) '  JSON::Parse: 0' >> META_new.yml
	$(NOECHO) $(ECHO) '  Lingua::EN::Inflect: 1.895' >> META_new.yml
	$(NOECHO) $(ECHO) '  Log::Message::Simple: 0.08' >> META_new.yml
	$(NOECHO) $(ECHO) '  Mojolicious: 4.22' >> META_new.yml
	$(NOECHO) $(ECHO) '  Path::Class: 0.32' >> META_new.yml
	$(NOECHO) $(ECHO) '  SQL::Abstract: 1.73' >> META_new.yml
	$(NOECHO) $(ECHO) '  SQL::Abstract::More: 1.15' >> META_new.yml
	$(NOECHO) $(ECHO) '  SQL::Translator: 0.11016' >> META_new.yml
	$(NOECHO) $(ECHO) '  String::CamelCase: 0.02' >> META_new.yml
	$(NOECHO) $(ECHO) '  YAML::Tiny: 1.51' >> META_new.yml
	$(NOECHO) $(ECHO) '  perl: 5.010001' >> META_new.yml
	$(NOECHO) $(ECHO) 'version: 0.50' >> META_new.yml
	-$(NOECHO) $(MV) META_new.yml $(DISTVNAME)/META.yml
	$(NOECHO) $(ECHO) Generating META.json
	$(NOECHO) $(ECHO) '{' > META_new.json
	$(NOECHO) $(ECHO) '   "abstract" : "unknown",' >> META_new.json
	$(NOECHO) $(ECHO) '   "author" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "dinni bartholomew <dinnibartholomew@gmail.com>"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "dynamic_config" : 1,' >> META_new.json
	$(NOECHO) $(ECHO) '   "generated_by" : "ExtUtils::MakeMaker version 6.78, CPAN::Meta::Converter version 2.132830",' >> META_new.json
	$(NOECHO) $(ECHO) '   "license" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "artistic_2"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "meta-spec" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",' >> META_new.json
	$(NOECHO) $(ECHO) '      "version" : "2"' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "name" : "Zoe",' >> META_new.json
	$(NOECHO) $(ECHO) '   "no_index" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "directory" : [' >> META_new.json
	$(NOECHO) $(ECHO) '         "t",' >> META_new.json
	$(NOECHO) $(ECHO) '         "inc"' >> META_new.json
	$(NOECHO) $(ECHO) '      ]' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "prereqs" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "build" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "configure" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "runtime" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBD::SQLite" : "1.37",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBI" : "1.623",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::GUID" : "0.046",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DateTime" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DateTime::Format::DBI" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "File::Copy::Recursive" : "0.38",' >> META_new.json
	$(NOECHO) $(ECHO) '            "File::Slurp" : "9999.19",' >> META_new.json
	$(NOECHO) $(ECHO) '            "File::Touch" : "0.08",' >> META_new.json
	$(NOECHO) $(ECHO) '            "JSON::Parse" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Lingua::EN::Inflect" : "1.895",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Log::Message::Simple" : "0.08",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Mojolicious" : "4.22",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Path::Class" : "0.32",' >> META_new.json
	$(NOECHO) $(ECHO) '            "SQL::Abstract" : "1.73",' >> META_new.json
	$(NOECHO) $(ECHO) '            "SQL::Abstract::More" : "1.15",' >> META_new.json
	$(NOECHO) $(ECHO) '            "SQL::Translator" : "0.11016",' >> META_new.json
	$(NOECHO) $(ECHO) '            "String::CamelCase" : "0.02",' >> META_new.json
	$(NOECHO) $(ECHO) '            "YAML::Tiny" : "1.51",' >> META_new.json
	$(NOECHO) $(ECHO) '            "perl" : "5.010001"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      }' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "release_status" : "stable",' >> META_new.json
	$(NOECHO) $(ECHO) '   "version" : "0.50"' >> META_new.json
	$(NOECHO) $(ECHO) '}' >> META_new.json
	-$(NOECHO) $(MV) META_new.json $(DISTVNAME)/META.json


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir distmeta 
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl.exe

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT></ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>dinni bartholomew &lt;dinnibartholomew@gmail.com&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <PERLCORE VERSION="5,010001,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBD::SQLite" VERSION="1.37" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBI::" VERSION="1.623" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::GUID" VERSION="0.046" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::Format::DBI" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="File::Copy::Recursive" VERSION="0.38" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="File::Slurp" VERSION="9999.19" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="File::Touch" VERSION="0.08" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="JSON::Parse" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Lingua::EN::Inflect" VERSION="1.895" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Log::Message::Simple" VERSION="0.08" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Mojolicious::" VERSION="4.22" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Path::Class" VERSION="0.32" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="SQL::Abstract" VERSION="1.73" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="SQL::Abstract::More" VERSION="1.15" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="SQL::Translator" VERSION="0.11016" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="String::CamelCase" VERSION="0.02" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="YAML::Tiny" VERSION="1.51" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="cygwin-thread-multi-64int-5.14" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/Zoe.pm blib/lib/Zoe.pm \
	  lib/Zoe/AuthenticationController.pm blib/lib/Zoe/AuthenticationController.pm \
	  lib/Zoe/AuthorizationManager.pm blib/lib/Zoe/AuthorizationManager.pm \
	  lib/Zoe/DO/Cart.pm blib/lib/Zoe/DO/Cart.pm \
	  lib/Zoe/DO/CartItem.pm blib/lib/Zoe/DO/CartItem.pm \
	  lib/Zoe/DataObject.pm blib/lib/Zoe/DataObject.pm \
	  lib/Zoe/DataObjectAuthenticationManager.pm blib/lib/Zoe/DataObjectAuthenticationManager.pm \
	  lib/Zoe/Example.pm blib/lib/Zoe/Example.pm \
	  lib/Zoe/Helpers.pm blib/lib/Zoe/Helpers.pm \
	  lib/Zoe/LDAPAuthenticationManager.pm blib/lib/Zoe/LDAPAuthenticationManager.pm \
	  lib/Zoe/ObjectMeta.pm blib/lib/Zoe/ObjectMeta.pm \
	  lib/Zoe/PayPayTransactionController.pm blib/lib/Zoe/PayPayTransactionController.pm \
	  lib/Zoe/PayPayTransactionController.pm_old blib/lib/Zoe/PayPayTransactionController.pm_old \
	  lib/Zoe/ZoeController.pm blib/lib/Zoe/ZoeController.pm \
	  lib/Zoe/Zoe_files/config/db.yml blib/lib/Zoe/Zoe_files/config/db.yml \
	  lib/Zoe/Zoe_files/public/assets/css/bootstrap-responsive.css blib/lib/Zoe/Zoe_files/public/assets/css/bootstrap-responsive.css \
	  lib/Zoe/Zoe_files/public/assets/css/bootstrap.css blib/lib/Zoe/Zoe_files/public/assets/css/bootstrap.css \
	  lib/Zoe/Zoe_files/public/assets/css/docs.css blib/lib/Zoe/Zoe_files/public/assets/css/docs.css \
	  lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-114-precomposed.png blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-114-precomposed.png \
	  lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-144-precomposed.png blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-144-precomposed.png \
	  lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-57-precomposed.png blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-57-precomposed.png \
	  lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-72-precomposed.png blib/lib/Zoe/Zoe_files/public/assets/ico/apple-touch-icon-72-precomposed.png \
	  lib/Zoe/Zoe_files/public/assets/ico/favicon.ico blib/lib/Zoe/Zoe_files/public/assets/ico/favicon.ico \
	  lib/Zoe/Zoe_files/public/assets/ico/favicon.png blib/lib/Zoe/Zoe_files/public/assets/ico/favicon.png \
	  lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings-white.png blib/lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings-white.png \
	  lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings.png blib/lib/Zoe/Zoe_files/public/assets/img/glyphicons-halflings.png \
	  lib/Zoe/Zoe_files/public/assets/js/README.md blib/lib/Zoe/Zoe_files/public/assets/js/README.md \
	  lib/Zoe/Zoe_files/public/assets/js/application.js blib/lib/Zoe/Zoe_files/public/assets/js/application.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-affix.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-affix.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-alert.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-alert.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-button.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-button.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-carousel.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-carousel.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-collapse.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-collapse.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-dropdown.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-dropdown.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-modal.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-modal.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-popover.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-popover.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-scrollspy.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-scrollspy.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-tab.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-tab.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-tooltip.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-tooltip.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-transition.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-transition.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap-typeahead.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap-typeahead.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap.js \
	  lib/Zoe/Zoe_files/public/assets/js/bootstrap.min.js blib/lib/Zoe/Zoe_files/public/assets/js/bootstrap.min.js \
	  lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.css blib/lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.css \
	  lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.js blib/lib/Zoe/Zoe_files/public/assets/js/google-code-prettify/prettify.js \
	  lib/Zoe/Zoe_files/public/assets/js/holder/holder.js blib/lib/Zoe/Zoe_files/public/assets/js/holder/holder.js \
	  lib/Zoe/Zoe_files/public/assets/js/html5shiv.js blib/lib/Zoe/Zoe_files/public/assets/js/html5shiv.js \
	  lib/Zoe/Zoe_files/public/assets/js/jquery.js blib/lib/Zoe/Zoe_files/public/assets/js/jquery.js \
	  lib/Zoe/Zoe_files/public/assets/js/jquery.min.map blib/lib/Zoe/Zoe_files/public/assets/js/jquery.min.map \
	  lib/Zoe/Zoe_files/public/assets/js/jquery.validate.js blib/lib/Zoe/Zoe_files/public/assets/js/jquery.validate.js \
	  lib/Zoe/Zoe_files/public/index.html blib/lib/Zoe/Zoe_files/public/index.html \
	  lib/Zoe/Zoe_files/t/00-data-scaffold.t blib/lib/Zoe/Zoe_files/t/00-data-scaffold.t \
	  lib/Zoe/Zoe_files/t/DataObject.t blib/lib/Zoe/Zoe_files/t/DataObject.t \
	  lib/Zoe/Zoe_files/t/DataObject.t_single_relationship_to_object blib/lib/Zoe/Zoe_files/t/DataObject.t_single_relationship_to_object \
	  lib/Zoe/Zoe_files/t/basic.t blib/lib/Zoe/Zoe_files/t/basic.t \
	  lib/Zoe/Zoe_files/t/t.pl blib/lib/Zoe/Zoe_files/t/t.pl \
	  lib/Zoe/Zoe_files/templates/cart.html.ep blib/lib/Zoe/Zoe_files/templates/cart.html.ep \
	  lib/Zoe/Zoe_files/templates/default.html.ep blib/lib/Zoe/Zoe_files/templates/default.html.ep \
	  lib/Zoe/Zoe_files/templates/example/welcome.html.ep blib/lib/Zoe/Zoe_files/templates/example/welcome.html.ep \
	  lib/Zoe/Zoe_files/templates/layouts/default.html.ep blib/lib/Zoe/Zoe_files/templates/layouts/default.html.ep \
	  lib/Zoe/Zoe_files/templates/model.tpl.pm blib/lib/Zoe/Zoe_files/templates/model.tpl.pm \
	  lib/Zoe/Zoe_files/templates/not_authorized.html.ep blib/lib/Zoe/Zoe_files/templates/not_authorized.html.ep \
	  lib/Zoe/Zoe_files/templates/not_authorized_html.ep blib/lib/Zoe/Zoe_files/templates/not_authorized_html.ep \
	  lib/Zoe/Zoe_files/templates/object_controller.tpl.pm blib/lib/Zoe/Zoe_files/templates/object_controller.tpl.pm \
	  lib/Zoe/Zoe_files/templates/paypal_transaction.html.ep blib/lib/Zoe/Zoe_files/templates/paypal_transaction.html.ep \
	  lib/Zoe/Zoe_files/templates/paypal_transaction_failed.html.ep blib/lib/Zoe/Zoe_files/templates/paypal_transaction_failed.html.ep \
	  lib/Zoe/Zoe_files/templates/routes.tpl blib/lib/Zoe/Zoe_files/templates/routes.tpl \
	  lib/Zoe/Zoe_files/templates/routes.tpl.yml blib/lib/Zoe/Zoe_files/templates/routes.tpl.yml \
	  lib/Zoe/Zoe_files/templates/routes.tpl_old blib/lib/Zoe/Zoe_files/templates/routes.tpl_old \
	  lib/Zoe/Zoe_files/templates/show_all_view.tpl blib/lib/Zoe/Zoe_files/templates/show_all_view.tpl \
	  lib/Zoe/Zoe_files/templates/show_auth_object_create_view.tpl blib/lib/Zoe/Zoe_files/templates/show_auth_object_create_view.tpl \
	  lib/Zoe/Zoe_files/templates/show_auth_object_edit_view.tpl blib/lib/Zoe/Zoe_files/templates/show_auth_object_edit_view.tpl \
	  lib/Zoe/Zoe_files/templates/show_create_view.tpl blib/lib/Zoe/Zoe_files/templates/show_create_view.tpl \
	  lib/Zoe/Zoe_files/templates/show_edit_view.tpl blib/lib/Zoe/Zoe_files/templates/show_edit_view.tpl \
	  lib/Zoe/Zoe_files/templates/show_view.tpl blib/lib/Zoe/Zoe_files/templates/show_view.tpl \
	  lib/Zoe/Zoe_files/templates/signin.html.ep blib/lib/Zoe/Zoe_files/templates/signin.html.ep \
	  lib/Zoe/Zoe_files/templates/startup_controller.tpl.pm blib/lib/Zoe/Zoe_files/templates/startup_controller.tpl.pm \
	  lib/Zoe/Zoe_files/templates/view_cart.html.ep blib/lib/Zoe/Zoe_files/templates/view_cart.html.ep \
	  lib/Zoe/Zoe_files/yml/mysql_example.yml blib/lib/Zoe/Zoe_files/yml/mysql_example.yml \
	  lib/Zoe/Zoe_files/yml/postgres_example.yml blib/lib/Zoe/Zoe_files/yml/postgres_example.yml \
	  lib/Zoe/Zoe_files/yml/sqlite_example.yml blib/lib/Zoe/Zoe_files/yml/sqlite_example.yml \
	  lib/Zoe/Zoe_files/yml/tutorial_example.yml blib/lib/Zoe/Zoe_files/yml/tutorial_example.yml \
	  lib/Zoe/public/assets/css/bootstrap-responsive.css blib/lib/Zoe/public/assets/css/bootstrap-responsive.css \
	  lib/Zoe/public/assets/css/bootstrap.css blib/lib/Zoe/public/assets/css/bootstrap.css \
	  lib/Zoe/public/assets/css/bootstrap.min.css blib/lib/Zoe/public/assets/css/bootstrap.min.css \
	  lib/Zoe/public/assets/css/docs.css blib/lib/Zoe/public/assets/css/docs.css \
	  lib/Zoe/public/assets/ico/apple-touch-icon-114-precomposed.png blib/lib/Zoe/public/assets/ico/apple-touch-icon-114-precomposed.png \
	  lib/Zoe/public/assets/ico/apple-touch-icon-144-precomposed.png blib/lib/Zoe/public/assets/ico/apple-touch-icon-144-precomposed.png \
	  lib/Zoe/public/assets/ico/apple-touch-icon-57-precomposed.png blib/lib/Zoe/public/assets/ico/apple-touch-icon-57-precomposed.png \
	  lib/Zoe/public/assets/ico/apple-touch-icon-72-precomposed.png blib/lib/Zoe/public/assets/ico/apple-touch-icon-72-precomposed.png \
	  lib/Zoe/public/assets/ico/favicon.ico blib/lib/Zoe/public/assets/ico/favicon.ico \
	  lib/Zoe/public/assets/ico/favicon.png blib/lib/Zoe/public/assets/ico/favicon.png \
	  lib/Zoe/public/assets/img/glyphicons-halflings-white.png blib/lib/Zoe/public/assets/img/glyphicons-halflings-white.png \
	  lib/Zoe/public/assets/img/glyphicons-halflings.png blib/lib/Zoe/public/assets/img/glyphicons-halflings.png \
	  lib/Zoe/public/assets/js/README.md blib/lib/Zoe/public/assets/js/README.md \
	  lib/Zoe/public/assets/js/application.js blib/lib/Zoe/public/assets/js/application.js \
	  lib/Zoe/public/assets/js/bootstrap-affix.js blib/lib/Zoe/public/assets/js/bootstrap-affix.js \
	  lib/Zoe/public/assets/js/bootstrap-alert.js blib/lib/Zoe/public/assets/js/bootstrap-alert.js \
	  lib/Zoe/public/assets/js/bootstrap-button.js blib/lib/Zoe/public/assets/js/bootstrap-button.js \
	  lib/Zoe/public/assets/js/bootstrap-carousel.js blib/lib/Zoe/public/assets/js/bootstrap-carousel.js \
	  lib/Zoe/public/assets/js/bootstrap-collapse.js blib/lib/Zoe/public/assets/js/bootstrap-collapse.js \
	  lib/Zoe/public/assets/js/bootstrap-dropdown.js blib/lib/Zoe/public/assets/js/bootstrap-dropdown.js \
	  lib/Zoe/public/assets/js/bootstrap-modal.js blib/lib/Zoe/public/assets/js/bootstrap-modal.js \
	  lib/Zoe/public/assets/js/bootstrap-popover.js blib/lib/Zoe/public/assets/js/bootstrap-popover.js \
	  lib/Zoe/public/assets/js/bootstrap-scrollspy.js blib/lib/Zoe/public/assets/js/bootstrap-scrollspy.js \
	  lib/Zoe/public/assets/js/bootstrap-tab.js blib/lib/Zoe/public/assets/js/bootstrap-tab.js \
	  lib/Zoe/public/assets/js/bootstrap-tooltip.js blib/lib/Zoe/public/assets/js/bootstrap-tooltip.js \
	  lib/Zoe/public/assets/js/bootstrap-transition.js blib/lib/Zoe/public/assets/js/bootstrap-transition.js \
	  lib/Zoe/public/assets/js/bootstrap-typeahead.js blib/lib/Zoe/public/assets/js/bootstrap-typeahead.js \
	  lib/Zoe/public/assets/js/bootstrap.js blib/lib/Zoe/public/assets/js/bootstrap.js \
	  lib/Zoe/public/assets/js/bootstrap.min.js blib/lib/Zoe/public/assets/js/bootstrap.min.js \
	  lib/Zoe/public/assets/js/google-code-prettify/prettify.css blib/lib/Zoe/public/assets/js/google-code-prettify/prettify.css \
	  lib/Zoe/public/assets/js/google-code-prettify/prettify.js blib/lib/Zoe/public/assets/js/google-code-prettify/prettify.js \
	  lib/Zoe/public/assets/js/holder/holder.js blib/lib/Zoe/public/assets/js/holder/holder.js \
	  lib/Zoe/public/assets/js/html5shiv.js blib/lib/Zoe/public/assets/js/html5shiv.js \
	  lib/Zoe/public/assets/js/jquery.js blib/lib/Zoe/public/assets/js/jquery.js \
	  lib/Zoe/public/assets/js/jquery.validate.js blib/lib/Zoe/public/assets/js/jquery.validate.js \
	  lib/Zoe/public/index.html blib/lib/Zoe/public/index.html \
	  lib/Zoe/templates/example/welcome.html.ep blib/lib/Zoe/templates/example/welcome.html.ep \
	  lib/Zoe/templates/layouts/default.html.ep blib/lib/Zoe/templates/layouts/default.html.ep \
	  lib/Zoe/templates/tutorial.html.ep blib/lib/Zoe/templates/tutorial.html.ep \
	  lib/Zoe/templates/upload.html.ep blib/lib/Zoe/templates/upload.html.ep 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
