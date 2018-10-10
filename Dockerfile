FROM ubuntu:18.04

ENV ROCKSDB_VERSION=5.14.3
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

# Install gflags from source to provide the cmake modules needed by RocksDB.
RUN \
    mkdir -p /tmpbuild/gflags && \
    cd /tmpbuild/gflags && \
    curl -L https://github.com/gflags/gflags/archive/v${GFLAGS_VERSION}.tar.gz -o gflags-${GFLAGS_VERSION}.tar.gz && \
    tar xfvz gflags-${GFLAGS_VERSION}.tar.gz && \
    cd /tmpbuild/gflags/gflags-${GFLAGS_VERSION} && \
    cmake -H. -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 && \
    cmake --build build --target install && \
    rm -Rf /tmpbuild/


# Install RocksDB from source.
RUN \
    mkdir -p /tmpbuild/rocksdb && \
    cd /tmpbuild/rocksdb && \
    curl -L https://github.com/facebook/rocksdb/archive/v${ROCKSDB_VERSION}.tar.gz -o rocksdb-${ROCKSDB_VERSION}.tar.gz && \
    tar xfvz rocksdb-${ROCKSDB_VERSION}.tar.gz && \
    cd /tmpbuild/rocksdb/rocksdb-${ROCKSDB_VERSION} && \
    cmake -H. -Bbuild -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_TESTS=0 \
        -DBUILD_SHARED_LIBS=1 \
        -DUSE_RTTI=1 && \
    cmake --build build --target install && \
    rm -Rf /tmpbuild/

RUN mkdir /build

WORKDIR /build

EXPOSE 8448

ENV CONSTRUCT_VERSION=e2bc5a524599ab5b762b65184ce9f0bd29d4ad52

RUN \
    curl -L https://github.com/matrix-construct/construct/archive/${CONSTRUCT_VERSION}.tar.gz \
        -o construct.tar.gz && \
    tar xf construct.tar.gz && \
    cd construct-${CONSTRUCT_VERSION} && \
    ./autogen.sh && ./configure --prefix=/app && make -j8 install && \
    rm -rf /build/*

ADD run.sh /run.sh

CMD [ "/run.sh" ]
