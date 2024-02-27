#!/usr/bin/env bash

# Install OS updates and packages as required for building DAOS on EL 9 and
# derivatives.  Include basic tools and daos dependencies that come from the core repos.

# This script use used by docker but can be invoked from elsewhere, in order to run it
# interactively then these two commands can be used to set dnf into automatic mode.
# dnf --assumeyes install dnf-plugins-core
# dnf config-manager --save --setopt=assumeyes=True

set -e

dnf --nodocs install \
    boost-devel \
    bzip2 \
    capstone-devel \
    clang \
    clang-tools-extra \
    cmake \
    CUnit-devel \
    diffutils \
    e2fsprogs \
    file \
    flex \
    fuse3 \
    fuse3-devel \
    gcc \
    gcc-c++ \
    git \
    glibc-langpack-en \
    graphviz \
    hdf5 \
    help2man \
    hwloc-devel \
    java-1.8.0-openjdk \
    json-c-devel \
    libaio-devel \
    libcmocka-devel \
    libevent-devel \
    libiscsi-devel \
    libtool \
    libtool-ltdl-devel \
    libunwind-devel \
    libuuid-devel \
    libyaml-devel \
    lz4-devel \
    make \
    ndctl \
    numactl \
    numactl-devel \
    openmpi-devel \
    openssl-devel \
    patch \
    patchelf \
    protobuf-c-devel \
    python3-devel \
    python3-pip \
    sg3_utils \
    sudo \
    valgrind-devel \
    wget \
    which \
    yasm

wget https://go.dev/dl/go1.21.6.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.6.linux-arm64.tar.gz
ln -s /usr/local/go/bin/go /usr/bin/
