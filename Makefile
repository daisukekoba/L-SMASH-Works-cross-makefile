# ----------------------------------------------------------------------------
# Copyright (c) 2013, KOBAYASHI Daisuke
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# ----------------------------------------------------------------------------

HOST = i686-w64-mingw32
CROSSPREFIX = $(HOST)-

GIT = git
TRUE = true

all: L-SMASH-Works.AviUtl.stamp L-SMASH-Works.VapourSynth.stamp
.PHONY: all

L-SMASH:
	$(GIT) clone git://github.com/silverfilain/$@.git

L-SMASH-Works libav zlib:
	$(GIT) clone git://github.com/VFR-maniac/$@.git

L-SMASH.stamp: BUILDDIR = L-SMASH.build
L-SMASH.stamp: L-SMASH
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR) && ../$</configure --prefix=$(PWD) \
		--cross-prefix=$(CROSSPREFIX)
	$(MAKE) -C $(BUILDDIR) lib
	$(MAKE) -C $(BUILDDIR) install-lib
	touch $@

zlib.stamp: zlib
	cd $< && CHOST=$(HOST) sh ./configure --prefix=$(PWD)
	$(MAKE) -C $< SHAREDLIBPOST=$(TRUE)
	$(MAKE) -C $< install SHAREDLIBPOST=$(TRUE)
	touch $@

LIBAV_COMPONENT = doc avconv avprobe avplay avdevice avfilter network \
	hwaccels encoders muxers outdevs devices filters
LIBAV_DISABLES = $(addprefix --disable-,$(LIBAV_COMPONENT))

libav.stamp: BUILDDIR = libav.build
libav.stamp: libav zlib.stamp
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR) && ../$</configure --prefix=$(PWD) \
		--enable-cross-compile --cross-prefix=$(CROSSPREFIX) \
		--target-os=mingw32 --arch=x86 --enable-gpl --disable-yasm \
		--disable-dxva2 $(LIBAV_DISABLES) \
		--extra-cflags="-I$(PWD)/include" --extra-libs="-L$(PWD)/lib"
	$(MAKE) -C $(BUILDDIR)
	$(MAKE) -C $(BUILDDIR) install
	touch $@

L-SMASH-Works.AviUtl.stamp: BUILDDIR = L-SMASH-Works/AviUtl.build
L-SMASH-Works.AviUtl.stamp: L-SMASH-Works L-SMASH.stamp libav.stamp zlib.stamp
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR) && sh ../AviUtl/configure --cross-prefix=$(CROSSPREFIX) \
		--extra-cflags="-I$(PWD)/include" --extra-ldflags="-L$(PWD)/lib" \
		--extra-libs="-lz"
	$(MAKE) -C $(BUILDDIR)
	cp $(BUILDDIR)/lsmashinput.aui .
	cp $(BUILDDIR)/lsmashmuxer.auf .
	cp $(BUILDDIR)/lsmashdumper.auf .
	touch $@

L-SMASH-Works.VapourSynth.stamp: BUILDDIR = L-SMASH-Works/VapourSynth.build
L-SMASH-Works.VapourSynth.stamp: L-SMASH-Works L-SMASH.stamp libav.stamp zlib.stamp
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR) && sh ../VapourSynth/configure --cross-prefix=$(CROSSPREFIX) \
		--extra-cflags="-I$(PWD)/include" --extra-ldflags="-L$(PWD)/lib" \
		--extra-libs="-lz"
	$(MAKE) -C $(BUILDDIR)
	cp $(BUILDDIR)/vslsmashsource.dll .
	touch $@

