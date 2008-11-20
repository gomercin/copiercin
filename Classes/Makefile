CC=arm-apple-darwin9-gcc
LD=$(CC)
CFLAGS=-I/var/include 
LDFLAGS=-L"/usr/lib" -F"/System/Library/Frameworks" -F"/System/Library/PrivateFrameworks" -bind_at_load \
	-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework CoreGraphics \
	-framework MobileMusicPlayer -multiply_defined suppress 

all:	TView
	/usr/bin/ldid -S TView

New:	TView.o
	$(LD) $(LDFLAGS) -o $@ $^


%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
		rm -f *.o TView

nice:
		rm -f *.o