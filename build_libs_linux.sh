#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ "$#" != 1 ]]; then
	echo "Usage: $0 <Debug or Release>"
	exit 1
fi

if [[ "$1" != "Debug" && "$1" != "Release" ]]; then
	echo "ERROR: Invalid build type '$1' (must be 'Debug' or 'Release', case-sensitive)."
	exit 1
fi

git submodule update --init --recursive

pushd godot-git-plugin/thirdparty/libgit2
cmake -B build \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_CLAR=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DUSE_SSH=OFF \
	-DUSE_HTTPS=OFF \
	-DUSE_BUNDLED_ZLIB=ON
cmake --build build --config "$1" -j"$(nproc)"
popd

mkdir -p demo/bin/x11
cp godot-git-plugin/thirdparty/libgit2/build/libgit2.a demo/bin/x11/libgit2.a

pushd godot-cpp
scons platform=linux target="$1" generate_bindings=yes bits=64 -j"$(nproc)"
popd
