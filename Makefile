love=love
zip=/usr/bin/zip
luac=/usr/bin/luac

builddir=build
distdir=dist

windir=love-bin/love-0.8.0-win-x86
osxapp=love-bin/love.app
lin32=love-bin/love32
lin64=love-bin/love64

game=defract
sources=*.lua */*.lua
res=
readme=README.markdown
version=0.1

distname = $(game)-$(version)

.PHONY : run test love clean win

run : test
	$(love) .

test :
	$(luac) -p $(sources)

dist : love win osx lin32 lin64

love : $(builddir)/$(game).love
	cp $(builddir)/$(game).love $(distdir)/$(game).love

osx : $(builddir)/$(game).app
	cd $(builddir); \
		zip -9 -q -r ../$(distdir)/$(distname).osx.zip $(game).app

win : $(builddir)/$(game).exe
	mkdir -p $(distdir)/$(distname)
	cp $(windir)/*.dll $(readme) $(builddir)/$(game).exe $(distdir)/$(distname)
	cd $(distdir); zip -q -r $(distname).win.zip $(distname)
	rm -rf $(distdir)/$(distname)

lin32 : $(builddir)/$(game)-i686
	mkdir -p $(distdir)/$(distname)
	cp $(builddir)/$(game)-i686 $(readme) $(distdir)/$(distname)
	cd $(distdir); zip -q -r $(distname)-i686.lin.zip $(distname)
	rm -rf $(distdir)/$(distname)

lin64 : $(builddir)/$(game)-x86_64
	mkdir -p $(distdir)/$(distname)
	cp $(builddir)/$(game)-i686 $(readme) $(distdir)/$(distname)
	cd $(distdir); zip -q -r $(distname)-x86_64.lin.zip $(distname)
	rm -rf $(distdir)/$(distname)

$(builddir)/$(game).app : $(builddir)/$(game).love
	cp -a $(osxapp) $(builddir)/$(game).app
	cp $(builddir)/$(game).love $(builddir)/$(game).app/Contents/Resources/
	cp $(readme) $(builddir)/$(game).app

$(builddir)/$(game).exe : $(builddir)/$(game).love
	cat $(windir)/love.exe $(builddir)/$(game).love > $(builddir)/$(game).exe

$(builddir)/$(game)-i686 : $(builddir)/$(game).love
	cat $(lin32) $(builddir)/$(game).love > $(builddir)/$(game)-i686
	chmod +x $(builddir)/$(game)-i686

$(builddir)/$(game)-x86_64 : $(builddir)/$(game).love
	cat $(lin64) $(builddir)/$(game).love > $(builddir)/$(game)-x86_64
	chmod +x $(builddir)/$(game)-x86_64

$(builddir)/$(game).love : $(sources) $(res)
	mkdir -p $(builddir)
	$(zip) $(builddir)/$(game).love $(sources) $(res)


clean :
	rm -rf $(builddir)/* $(distdir)/*
