#
# Makefile for WinBoard, using Microsoft Visual C++ and nmake
# Command line:   nmake /f msvc.mak
#

OS=NT
ENV=WIN32
CPU=i386

!include <$(OS)$(ENV).MAK>

# Use up to date help compiler
hc=hcrtf.exe -xn

# Comment out both to turn on debugging symbols #######
cdebug=
linkdebug=
#######################################################

proj = winboard
allobj = winboard.obj backend.obj parser.obj moves.obj lists.obj \
	 gamelist.obj pgntags.obj wedittags.obj wgamelist.obj zippy.obj \
         wsockerr.obj wclipbrd.obj woptions.obj

cvars = $(cvars) -I. -I.. -DWINVER=0x0400
#cflags = $(cflags) /FR
cflags = $(cflags)

all: $(proj).exe

clean:
	rm -f *.obj *~ $(proj).exe $(proj).err $(proj).rbj $(proj).res \
	  $(proj).ini *.sbr *.bsc *.o *.plg *.opt *.ncb *.debug *.bak *.gid

# Update the help file if necessary
$(proj).hlp : $(proj).rtf
    $(hc) $(proj).hpj
    type $(proj).err

# Update the resource if necessary
$(proj).rbj: $(proj).rc $(proj).h $(proj).res resource.h
    $(rc) $(rcvars) -r -fo $(proj).res $(proj).rc
    cvtres  /machine:X86 /out:$(proj).rbj $(proj).res

# Update the object files if necessary
winboard.obj: winboard.c config.h winboard.h ../common.h ../frontend.h \
        ../backend.h ../moves.h wgamelist.h defaults.h resource.h wclipbrd.h \
        wedittags.h wsockerr.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) winboard.c

backend.obj: ../backend.c config.h ../common.h ../frontend.h ../backend.h \
        ../parser.h ../moves.h ../zippy.h ../backendz.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../backend.c

parser.obj: parser.c config.h ../common.h ../backend.h ../parser.h \
        ../frontend.h ../moves.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) parser.c

parser.c: ../parser.l
    flex -oparser.c -L ../parser.l

moves.obj: ../moves.c config.h ../backend.h ../common.h ../parser.h \
        ../moves.h ../lists.h ../frontend.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../moves.c

lists.obj: ../lists.c config.h ../lists.h ../common.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../lists.c

gamelist.obj: ../gamelist.c config.h ../lists.h ../common.h ../frontend.h \
        ../backend.h ../parser.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../gamelist.c

pgntags.obj: ../pgntags.c config.h ../common.h ../frontend.h ../backend.h \
    ../parser.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../pgntags.c

wclipbrd.obj: wclipbrd.c config.h ../common.h ../frontend.h ../backend.h \
              winboard.h wclipbrd.h ../lists.h resource.h
    $(cc) $(cflags) $(cvars) $(cdebug) wclipbrd.c

wedittags.obj: wedittags.c config.h ../common.h winboard.h ../frontend.h \
        ../backend.h ../lists.h resource.h
    $(cc) $(cflags) $(cvars) $(cdebug) wedittags.c

wgamelist.obj: wgamelist.c config.h. ../common.h winboard.h ../frontend.h \
        ../backend.h wgamelist.h ../lists.h resource.h
    $(cc) $(cflags) $(cvars) $(cdebug) wgamelist.c

woptions.obj: woptions.c config.h ../common.h ../frontend.h ../backend.h \
	../lists.h defaults.h
    $(cc) $(cflags) $(cvars) $(cdebug) woptions.c

wsockerr.obj: wsockerr.c wsockerr.h
    $(cc) $(cflags) $(cvars) $(cdebug) wsockerr.c

zippy.obj: ../zippy.c config.h ../common.h ../zippy.h ../frontend.h \
	../backend.h ../backendz.h ../lists.h
    $(cc) $(cflags) $(cvars) $(cdebug) ../zippy.c

$(proj).exe: $(allobj) $(proj).rbj $(proj).hlp $(proj).rc
    $(link) $(linkdebug) /NODEFAULTLIB:LIBCD $(guiflags) $(allobj) \
	wsock32.lib comctl32.lib winmm.lib libc.lib oldnames.lib kernel32.lib \
	advapi32.lib user32.lib gdi32.lib comdlg32.lib winspool.lib \
	ws2_32.lib \
	$(proj).rbj -out:$(proj).exe
# I don't use the .sbr, but it can be reenabled.  Also turn /FR back on above.
#	bscmake *.sbr

test.exe: test.c
	$(cc) $(cflags) $(cvars) $(cdebug) test.c
	$(link) $(linkdebug) $(conflags) test.obj $(conlibs) -out:test.exe

