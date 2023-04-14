$ErrorActionPreference = 'Continue'


if "${{ matrix.backend }}" == "dpcpp" (
            set ninja_targets="build-onedpl-sycl_iterator-tests"
            set ctest_flags=-R sycl_iterator_.*\.pass
            echo ::warning::dpcpp backend is set. Compile and run only sycl_iterator tests
          ) else (
            set ninja_targets=build-onedpl-tests
          )
          if "${{ matrix.cxx_compiler }}" == "icpx" set TMP_INTEL_LLVM_COMPILER=TRUE
          if "${{ matrix.cxx_compiler }}" == "icx" set TMP_INTEL_LLVM_COMPILER=TRUE
          if "${{ matrix.cxx_compiler }}" == "icx-cl" set TMP_INTEL_LLVM_COMPILER=TRUE
          if "${{ matrix.cxx_compiler }}" == "dpcpp" set TMP_INTEL_LLVM_COMPILER=TRUE
          if "${{ matrix.cxx_compiler }}" == "dpcpp-cl" set TMP_INTEL_LLVM_COMPILER=TRUE
          if "%TMP_INTEL_LLVM_COMPILER%" == "TRUE" (
            powershell $output = ${{ matrix.cxx_compiler }} --version; Write-Host ::warning::Compiler: $output
            powershell -Command "(Get-Content '%CONDA_PREFIX%\Library\lib\cl.cfg') -replace 'CL_CONFIG_TBB_DLL_PATH = .*', 'CL_CONFIG_TBB_DLL_PATH = %CONDA_PREFIX%\Library\bin' | Out-File -encoding ASCII -FilePath '%CONDA_PREFIX%\Library\lib\cl.cfg'"
          )
          
          
set INCLUDE=%CONDA_PREFIX%\Library\include;%INCLUDE%
set LIB=%CONDA_PREFIX%\Library\lib;%LIB%
set PATH=%CONDA_PREFIX%\Library\lib;%PATH%
set CPATH=%CONDA_PREFIX%\include
set TBB_DLL_PATH=%CONDA_PREFIX%\Library\bin
reg add HKLM\SOFTWARE\khronos\OpenCL\Vendors /v intelocl64.dll /t REG_DWORD /d 00000000
          
          
# gmake program arguments
$cmd_args = @"
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
mkdir build && cd build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=${{ matrix.build_type }} -DCMAKE_CXX_STANDARD=${{ matrix.std }} -DCMAKE_CXX_COMPILER=${{ matrix.cxx_compiler }} -DONEDPL_BACKEND=${{ matrix.backend }} -DONEDPL_DEVICE_TYPE=${{ matrix.device_type }} ..
ninja -j 2 -v %ninja_targets%
ctest --timeout %TEST_TIMEOUT% -C ${{ matrix.build_type }} --output-on-failure %ctest_flags%
"@


$cmd_args = [string]::join(" ", ($cmd_args.Split("`n")))
cmd /v /c $cmd_args

exit ${LastExitCode}
