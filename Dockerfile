FROM ubuntu:24.04 AS compile-image

RUN apt-get update && apt-get install -y build-essential clang flex bison g++ gawk gcc-multilib \
    g++-multilib gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig unzip zlib1g-dev \
    file wget curl zstd libcurl4-openssl-dev nano vim

FROM compile-image AS openwrt-builder
WORKDIR /workdir
RUN git clone --depth 1 https://github.com/openwrt/openwrt.git /workdir/openwrt/
RUN git clone --depth 1 https://github.com/gSpotx2f/luci-app-temp-status.git /workdir/openwrt/package/app/luci-app-temp-status/
WORKDIR /workdir/openwrt
RUN ./scripts/feeds update -a && ./scripts/feeds install -a
COPY openwrt /workdir/openwrt
ENV FORCE_UNSAFE_CONFIGURE=1
ENV NO_JEVENTS=1
RUN make defconfig && make -j$(nproc)

FROM compile-image
WORKDIR /workdir/openwrt
COPY --from=openwrt-builder /workdir/openwrt/bin/ /workdir/openwrt/bin/
