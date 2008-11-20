# Makefile for gcc compiler for iPhone

PROJECTNAME=CopierciN

CC=arm-apple-darwin9-gcc
LD=$(CC)
LDFLAGS = -arch arm -lobjc -lsqlite3 
LDFLAGS += -framework CoreFoundation 
LDFLAGS += -framework Foundation 
LDFLAGS += -framework UIKit 
LDFLAGS += -framework AddressBook 
LDFLAGS += -framework GraphicsServices
LDFLAGS += -L"/usr/lib"
LDFLAGS += -F"/System/Library/Frameworks"
LDFLAGS += -F"/System/Library/PrivateFrameworks"

CFLAGS = -I"/private/var/include" 
#CFLAGS = -I"/private/var/mobile/Development/2.0FrameworkHeaders" 
CFLAGS += -I"/usr/include" 
CFLAGS += -F"/System/Library/Frameworks" 
CFLAGS += -F"/System/Library/PrivateFrameworks" 
CFLAGS += -DDEBUG -O3 -Wall -std=c99 -funroll-loops
CFLAGS += -DMAC_OS_X_VERSION_MAX_ALLOWED=1050

BUILDDIR=./build/2.0
SRCDIR=./Classes
RESDIR=./Resources
OBJS=$(patsubst %.m,%.o,$(wildcard $(SRCDIR)/*.m))
OBJS+=$(patsubst %.c,%.o,$(wildcard $(SRCDIR)/*.c))
OBJS+=$(patsubst %.cpp,%.o,$(wildcard $(SRCDIR)/*.cpp))
RESOURCES=$(wildcard $(RESDIR)/*)
APPFOLDER=Copiercin.app
INSTALLFOLDER=Copiercin.app

all:	dist

$(PROJECTNAME):	$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.cpp
	$(CC) -c $(CPPFLAGS) $< -o $@

dist:	$(PROJECTNAME)
	/bin/rm -rf $(BUILDDIR)
	/bin/mkdir -p $(BUILDDIR)/$(APPFOLDER)
	/bin/cp $(RESDIR)/* $(BUILDDIR)/$(APPFOLDER)
	/bin/cp Info.plist $(BUILDDIR)/$(APPFOLDER)/Info.plist
	@echo "APPL????" > $(BUILDDIR)/$(APPFOLDER)/PkgInfo
	/usr/bin/ldid -S $(PROJECTNAME)
	rm /Applications/Copiercin.app/copiercin
	/bin/cp $(PROJECTNAME) /Applications/Copiercin.app/copiercin

install: dist
	/bin/cp -r $(BUILDDIR)/$(APPFOLDER) /Applications/$(INSTALLFOLDER)
	@echo "Application $(INSTALLFOLDER) installed"
	appLoad

uninstall:
	/bin/rm -fr /Applications/$(INSTALLFOLDER)
	appLoad 1

clean:
	@rm -f $(SRCDIR)/*.o
	@rm -rf $(BUILDDIR)
	@rm -f $(PROJECTNAME)

