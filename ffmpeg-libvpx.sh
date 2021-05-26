#!/bin/bash

function run_depends {
	sudo apt-get update -qq && sudo apt-get upgrade && sudo apt-get -y install \
	autoconf \
	automake \
	build-essential \
	cmake \
	git-core \
	libass-dev \
	libfreetype6-dev \
	libgnutls28-dev \
	libsdl2-dev \
	libtool \
	libva-dev \
	libvdpau-dev \
	libvorbis-dev \
	libxcb1-dev \
	libxcb-shm0-dev \
	libxcb-xfixes0-dev \
	meson \
	ninja-build \
	pkg-config \
	texinfo \
	wget \
	yasm \
	zlib1g-dev \
	libunistring-dev
}

function run_prepare {
	mkdir -p ~/ffmpeg_sources ~/bin
}

function run_nasm {
	cd ~/ffmpeg_sources && \
	wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 && \
	tar xjvf nasm-2.15.05.tar.bz2 && \
	cd nasm-2.15.05 && \
	./autogen.sh && \
	PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
	make && \
	make install
}

function run_libx264 {
	cd ~/ffmpeg_sources && \
	git -C x264 pull 2>/dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
	cd x264 && \
	PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
	PATH="$HOME/bin:$PATH" make && \
	make install
}

function run_libvpx {
	cd ~/ffmpeg_sources && \
	git -C libvpx pull 2>/dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
	cd libvpx && \
	PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
	PATH="$HOME/bin:$PATH" make && \
	make install
}

function run_libfdk-aac {
	cd ~/ffmpeg_sources && \
	git -C fdk-aac pull 2>/dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
	cd fdk-aac && \
	autoreconf -fiv && \
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
	make && \
	make install
}

function run_opus {
	cd ~/ffmpeg_sources && \
	git -C opus pull 2>/dev/null || git clone --depth 1 https://github.com/xiph/opus.git && \
	cd opus && \
	./autogen.sh && \
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
	make && \
	make install
}

function run_all {
	cd ~/ffmpeg_sources && \
	wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
	tar xjvf ffmpeg-snapshot.tar.bz2 && \
	cd ffmpeg && \
	PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
	--prefix="$HOME/ffmpeg_build" \
	--pkg-config-flags="--static" \
	--extra-cflags="-I$HOME/ffmpeg_build/include" \
	--extra-ldflags="-L$HOME/ffmpeg_build/lib" \
	--extra-libs="-lpthread -lm" \
	--ld="g++" \
	--bindir="$HOME/bin" \
	--enable-gpl \
	--enable-gnutls \
	--enable-libass \
	--enable-libfdk-aac \
	--enable-libfreetype \
	--enable-libopus \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libx264 \
	--enable-nonfree && \
	PATH="$HOME/bin:$PATH" make && \
	make install && \
	hash -r
}

function run_allright {
	sudo rm -rf ~/ffmpeg_build ~/ffmpeg_sources && /
	echo "ALLRIGHT, EVERYTHING WAS INSTALLED!!"
}

run_depends
run_prepare
run_nasm
run_libx264
run_libvpx
run_libfdk-aac
run_opus
run_all
run_allright