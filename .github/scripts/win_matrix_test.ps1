$ErrorActionPreference = 'Continue'


# gmake program arguments
$cmd_args = @"
"C:\Program Files (x86)\Microsoft Visual Studio\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
mkdir build && cd build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=${{ matrix.build_type }} -DCMAKE_CXX_STANDARD=${{ matrix.std }} -DCMAKE_CXX_COMPILER=${{ matrix.cxx_compiler }} -DONEDPL_BACKEND=${{ matrix.backend }} -DONEDPL_DEVICE_TYPE=${{ matrix.device_type }} ..
ninja -j 2 -v %ninja_targets%
ctest --timeout %TEST_TIMEOUT% -C ${{ matrix.build_type }} --output-on-failure %ctest_flags%
"@


$cmd_args = [string]::join(" ", ($cmd_args.Split("`n")))
cmd /v /c $cmd_args

exit ${LastExitCode}
