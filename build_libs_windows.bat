git submodule update --init --recursive

pushd godot-git-plugin\thirdparty\libgit2
cmake -B build -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_CLAR=OFF -DBUILD_EXAMPLES=OFF -DUSE_SSH=OFF -DUSE_HTTPS=OFF -DUSE_BUNDLED_ZLIB=ON -DWINHTTP=OFF
cmake --build build --config %1 -j%NUMBER_OF_PROCESSORS%
popd

mkdir demo\bin\win64
copy "godot-git-plugin\thirdparty\libgit2\build\%1\git2.lib" demo\bin\win64

if "%CI%"=="" (
    set SCONS=scons
) else (
    echo CI build detected, modifying the SCons executable path.
    set SCONS=..\scons.bat
)

pushd godot-cpp
%SCONS% platform=windows target=%1 generate_bindings=yes bits=64 -j%NUMBER_OF_PROCESSORS%
popd
