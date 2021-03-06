FROM ubuntu:18.04

ENV ROCKSDB_VERSION=5.15.10
ENV GFLAGS_VERSION=2.2.1
ENV CXX=g++-8
ENV CC=gcc-8

RUN \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:mhier/libboost-latest && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y boost1.67 cmake && \
    apt-get install -y xz-utils ${CXX} ${CC} build-essential git curl ninja-build \
                       libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libzstd-dev \
                       libsodium-dev libssl1.0-dev openssl \
                       libtool automake autotools-dev libmagic-dev \
                       autoconf autoconf2.13 autoconf-archive shtool
RUN \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/${CC} 10 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/${CXX} 10

RUN \
    mkdir -p /tmpbuild/gflags && \
    cd /tmpbuild/gflags && \
    curl -L https://github.com/gflags/gflags/archive/v${GFLAGS_VERSION}.tar.gz -o gflags-${GFLAGS_VERSION}.tar.gz && \
    tar xfvz gflags-${GFLAGS_VERSION}.tar.gz && \
    cd /tmpbuild/gflags/gflags-${GFLAGS_VERSION} && \
    cmake -H. -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 && \
    cmake --build build --target install && \
    rm -Rf /tmpbuild/


RUN \
    mkdir -p /tmpbuild/rocksdb && \
    cd /tmpbuild/rocksdb && \
    curl -L https://github.com/facebook/rocksdb/archive/v${ROCKSDB_VERSION}.tar.gz -o rocksdb-${ROCKSDB_VERSION}.tar.gz && \
    tar xfvz rocksdb-${ROCKSDB_VERSION}.tar.gz && \
    cd /tmpbuild/rocksdb/rocksdb-${ROCKSDB_VERSION} && \
    cmake -H. -Bbuild -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_TESTS=0 \
        -DWITH_TOOLS=0 \
        -DBUILD_SHARED_LIBS=1 \
        -DWITH_SNAPPY=1 \
        -DWITH_ZLIB=1 \
        -DUSE_RTTI=1 && \
    cmake --build build --target install && \
    rm -Rf /tmpbuild/

RUN mkdir /build

WORKDIR /build

EXPOSE 8448

ENV CONSTRUCT_VERSION=f9fca347d8ce910299f69231c44cabbb6410101d

RUN \
    curl -L https://github.com/matrix-construct/construct/archive/${CONSTRUCT_VERSION}.tar.gz \
        -o construct.tar.gz && \
    tar xf construct.tar.gz && \
    cd construct-${CONSTRUCT_VERSION} && \
    ./autogen.sh && ./configure --prefix=/app && make -j8 install && \
    rm -rf /build/*

ADD run.sh /run.sh

CMD [ "/run.sh" ]
